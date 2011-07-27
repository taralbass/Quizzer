module Switchboard
  module InlineControl

    def self.included client_module
      client_module.extend ClassMethods
    end

    module ClassMethods

      attr_accessor :target_class, :target_symbol, :initialize_for_new_method,
                    :initialize_for_create_method, :show_partial, :new_partial

      alias :inlinified_target_class :target_class=
      alias :inlinified_target_symbol :target_symbol=
      alias :inlinified_initialize_for_new_method :initialize_for_new_method=
      alias :inlinified_initialize_for_create_method :initialize_for_create_method=
      alias :inlinified_show_partial :show_partial=
      alias :inlinified_new_partial :new_partial=

      def inlinify! *args
        set_defaults
        args = [ :show, :new, :create, :edit, :update, :destroy ] unless args.size > 0
        args.each { |a| send('inlinify_' + a.to_s + '!') }
        before_filter :inlinify_require_xhr, :only => args
        before_filter :scrub_target_params!, :only => [ :create, :update ] & args
      end
      
      private

      def set_defaults
        self.target_class ||= default_target_class
        self.target_symbol ||= self.target_class.name.underscore.to_sym
        self.show_partial ||= self.target_class.name.pluralize.underscore + '/' + self.target_class.name.underscore
        self.new_partial ||= self.target_class.name.pluralize.underscore + '/new'
      end

      def default_target_class
        class_name = self.name.gsub(/Controller$/, '').split('::').pop.singularize rescue nil
        default_class = class_name.constantize rescue nil
        default_class.is_a? Class or raise ::Switchboard::Error, "unable to deterimine target for #{self.name}: #{class_name} is not a class"
        default_class
      end
      
      def inlinify_show!
        define_method :show do
          if attr
            render :template => "shared/display_inline",
                   :locals => { :target => target_by_param_id, :attr => attr }
          else
            render :template => "shared/display_inline_object",
                   :locals => { self.class.target_symbol => target_by_param_id, :partial => self.class.show_partial, :new_form_id => params[:new_form_id] }
          end
        end
      end
      
      def inlinify_new!
        define_method :new do
          args = params[self.class.target_symbol]
          target = self.class.initialize_for_new_method ?
            send(self.class.initialize_for_new_method, args) : self.class.target_class.new(args)

          render :template => "shared/display_new_inline_object",
                 :locals => { self.class.target_symbol => target, :partial => self.class.new_partial,
                              :starting_new_form_id => params[:starting_new_form_id].to_i, :count => params[:count].to_i }
        end
      end

      def inlinify_create!
        define_method :create do
          args = params[self.class.target_symbol]
          target = self.class.initialize_for_create_method ?
            send(self.class.initialize_for_create_method, args) : self.class.target_class.new(args)

          if target.save
            render :template => "shared/handle_successful_inline_creation",
                   :locals => { :target => target, :new_form_id => params[:new_form_id] }
          else
            render :template => "shared/handle_failed_inline_creation",
                   :locals => { :target => target, :new_form_id => params[:new_form_id] }
          end
        end
      end
      
      def inlinify_edit!
        define_method :edit do
          partial = "#{self.class.target_class.name.pluralize.underscore}/#{attr!}_input"
          render :template => 'shared/edit_inline',
                 :locals => { :target => target_by_param_id, :attr => attr!, :partial => partial }
        end
      end

      def inlinify_update!
        define_method :update do
          # although using only one attribute, update via update_attributes to
          # avoid inadvertently circumventing accessibility settings
          if target_by_param_id.update_attributes(attr! => params[self.class.target_symbol][attr!])
            render :template => "shared/handle_successful_inline_update",
                   :locals => { :target => target_by_param_id, :attr => attr! }
          else
            render :template => "shared/handle_failed_inline_update",
                   :locals => { :target => target_by_param_id, :attr => attr! }
          end
        end
      end
      
      def inlinify_destroy!
        define_method :destroy do
          target = target_by_param_id.destroy
          render :template => "shared/handle_successful_inline_deletion", :locals => { :target => target }
        end
      end
      
    end
    

    private

    def target_by_param_id
      @target ||= self.class.target_class.find(params[:id])
    end

    # for now at least, only allow accessible attributes -- don't want inline editing to bypass
    # attribute protection. prefer noisy fail to silent fail of update_attributes.
    def attr
      if !instance_variable_defined? '@attr' and params[:attr] and self.class.target_class.accessible_attributes.exclude? params[:attr]
        raise ArgumentError, "invalid or inaccessible attribute requested: #{params[:attr]}"
      end
      @attr ||= params[:attr]
    end

    def attr!
      attr or raise ArgumentError, "no attribute provided"
    end

    def inlinify_require_xhr
      request.xhr? or raise ArgumentError, "xhr request required"
    end

    def sanitize str
      [ /\r\n/, /\n\r/, /\r/ ].each { |regex| str.gsub!(regex, "\n") }
      str
    end

    def scrub_param_values params_root
      params_root ||= {}
      params_root.each do |key, value|
        params_root[key] = case value
          when Hash then scrub_param_values(value)
          when Array then value.collect { |e| sanitize(e) }
          when Symbol then value
          else sanitize(value)
        end
      end
      params_root
    end

    def scrub_target_params!
      params[self.class.target_symbol] = scrub_param_values(params[self.class.target_symbol])
    end
  end
end
