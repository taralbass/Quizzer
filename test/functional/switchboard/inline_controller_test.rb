require 'test_helper'

class InlineControllerTest < ActionController::TestCase
  # To avoid relying on object that might change, create Ox and
  # OxenController classes that mimic the relationship between an
  # ActiveRecord object and a corresponding controller. Classes are
  # kept anonymous to avoid cluttering the namespace/conflicting
  # with other tests that do the same thing.

  anonymous_ox_class = Struct.new(:id, :attribute) do
    def self.name; "Ox"; end
    def self.accessible_attributes; [ :attribute ]; end
    def save; true; end
    def update_attributes *args; true; end
    def errors
      # only mock errors if update_attributes/save are not stubbed to return false
      return {} if update_attributes && save
      mock_errors = Object.new
      def mock_errors.full_messages; ["a", "b"]; end
      mock_errors
    end
    def destroy; self; end

    # needed to mock functionality used in rendering forms for object
    def self.model_name; ActiveModel::Name.new(self); end
    def self.find; end
    def to_key; [self.id]; end

    def initialize args={}
      args ||= {}
      super args[:id], args[:attribute]

      self.class.stubs(:find).with(self.id).returns(self)
    end
  end

  anonymous_oxen_controller_class = Class.new ApplicationController do
    def self.name; "OxenController"; end
    include Switchboard::InlineControl
    inlinified_target_class anonymous_ox_class
    inlinify!
  end

  tests anonymous_oxen_controller_class

  setup do
    @ox = anonymous_ox_class.new(:id => 123, :attribute => :value)
  end

  context "on index" do
    should "raise ActionController::RoutingError" do
      assert_raises AbstractController::ActionNotFound do
        with_oxen_routing do
          get :index
        end
      end
    end
  end

  context "on show" do
    context "with an attr param" do
      setup do
        with_oxen_routing do
          xhr :get, :show, :id => 123, :attr => :attribute
        end
      end

      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render template shared/display_inline with correct locals" do
        @controller.expects(:render).with(:template => 'shared/display_inline', :locals => { :target => @ox, :attr => :attribute })
        @controller.expects(:render).with()
      end
    end

    context "without an attr param" do
      context "" do
        setup do
          ActionView::Partials::PartialRenderer.any_instance.stubs(:render)
          with_oxen_routing do
            xhr :get, :show, :id => 123, :new_form_id => 5
          end
        end

        should respond_with(:success)
        should_not render_with_layout(:application)
        should_not set_the_flash
        should respond_with_content_type(:js)

        before_should "render template shared/display_inline_object with correct locals" do 
          @controller.expects(:render).with(:template => 'shared/display_inline_object', :locals => { :ox => @ox, :partial => "oxen/ox", :new_form_id => 5 })
          @controller.expects(:render).with()
        end
      end
    end

    context "with a non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            get :show, :id => 123
          end
        end
      end
    end
  end

  context "on new" do
    context "" do
      setup do
        with_oxen_routing do
          ActionView::Partials::PartialRenderer.any_instance.stubs(:render)
          xhr :get, :new, :starting_new_form_id => 5, :count => 3
        end
      end
      
      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render template shared/display_new_inline_object with correct locals" do
        @controller.expects(:render).with(:template => "shared/display_new_inline_object",
                                          :locals => { :ox => anonymous_ox_class.new, :partial => 'oxen/new', :starting_new_form_id => 5, :count => 3 })
        @controller.expects(:render).with()
      end

      before_should "render template shared/display_new_inline_object with custom initialized target" do
        def @controller.initialize_for_new *args; :initialized_target; end
        @controller.class.stubs(:initialize_for_new_method).returns(:initialize_for_new)
        @controller.expects(:render).with(:template => "shared/display_new_inline_object",
                                          :locals => { :ox => :initialized_target, :partial => 'oxen/new', :starting_new_form_id => 5, :count => 3 })
        @controller.expects(:render).with()
      end
    end

    context "with non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            get :new
          end
        end
      end
    end
  end

  context "on create" do
    context "with a successful creation" do
      setup do
        with_oxen_routing do
          xhr :post, :create, { :ox => { :attribute => :value }, :new_form_id => 1 }
        end
      end

      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render shared/handle_successful_inline_creation" do
        @controller.expects(:render).with(:template => 'shared/handle_successful_inline_creation',
          :locals => { :target => anonymous_ox_class.new(:attribute => :value), :new_form_id => 1 })
        @controller.expects(:render).with()
      end

      before_should "save new instance" do
        ox = anonymous_ox_class.new(:attribute => :value)
        anonymous_ox_class.expects(:new).with('attribute' => :value).returns(ox)
        ox.expects(:save).returns(true)
      end

      before_should "trigger before filter :scrub_target_params!" do
        @controller.expects(:scrub_target_params!)
      end
    end

    context "with a failed creation" do
      setup do
        anonymous_ox_class.any_instance.stubs(:save).returns(false)
        with_oxen_routing do
          xhr :post, :create, { :ox => { :attribute => :value }, :new_form_id => 1 }
        end
      end

      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render shared/handle_failed_inline_creation" do
        @controller.expects(:render).with(:template => 'shared/handle_failed_inline_creation',
          :locals => { :target => anonymous_ox_class.new(:attribute => :value), :new_form_id => 1 })
        @controller.expects(:render).with()
      end
    end

    context "with non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            post :create, { :ox => { :attribute => :value }, :new_form_id => 1 }
          end
        end
      end
    end
  end

  context "on edit" do
    context "" do
      setup do
        with_oxen_routing do
          ActionView::Partials::PartialRenderer.any_instance.stubs(:render)
          xhr :get, :edit, :id => 123, :attr => :attribute
        end
      end
      
      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render template shared/edit_inline with correct locals" do
        @controller.expects(:render).with(:template => 'shared/edit_inline', :locals => { :target => @ox, :attr => :attribute, :partial => 'oxen/attribute_input' })
        @controller.expects(:render).with()
      end
    end

    context "with non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            get :edit, :id => 123, :attr => :attribute
          end
        end
      end
    end
  end

  context "on update" do
    context "with a successful update" do
      context "" do
        setup do
          @ox.stubs(:update_attributes).returns(true)
          with_oxen_routing do
            xhr :put, :update, :id => 123, :attr => :attribute, :ox => { :attribute => :new_value }
          end
        end

        should respond_with(:success)
        should_not render_with_layout(:application)
        should_not set_the_flash
        should respond_with_content_type(:js)

        before_should "render template shared/handle_successful_inline_update with correct locals" do
          @controller.expects(:render).with(:template => 'shared/handle_successful_inline_update', :locals => { :target => @ox, :attr => :attribute })
          @controller.expects(:render).with()
        end

        before_should "trigger before filter :scrub_target_params!" do
          @controller.expects(:scrub_target_params!)
        end
      end

      before_should "update indicated attribute" do
        @ox.expects(:update_attributes).returns(true)
        with_oxen_routing do
          xhr :put, :update, :id => 123, :attr => :attribute, :ox => { :attribute => :new_value }
        end
      end
    end

    context "that has an unsuccessful update" do
      setup do
        @ox.stubs(:update_attributes).returns(false)
        with_oxen_routing do
          xhr :put, :update, :id => 123, :attr => :attribute, :ox => { :attribute => :new_value }
        end
      end
      
      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render template shared/handle_failed_inline_update with correct locals" do
        @controller.expects(:render).with(:template => 'shared/handle_failed_inline_update', :locals => { :target => @ox, :attr => :attribute })
        @controller.expects(:render).with()
      end
    end

    context "with non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            put :update, :id => 123, :attr => :attribute, :ox => { :attribute => :new_value }
          end
        end
      end
    end
  end

  context "on destroy" do
    context "" do
      setup do
        with_oxen_routing do
          xhr :delete, :destroy, :id => 123
        end
      end

      should respond_with(:success)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "render template shared/handle_successful_inline_deletion" do
        @controller.expects(:render).with(:template => 'shared/handle_successful_inline_deletion', :locals => { :target => @ox })
        @controller.expects(:render).with()
      end

      before_should "destroy the target" do
        @ox.expects(:destroy).returns(@ox)
      end
    end

    context "with non-xhr request" do
      should "raise an ArgumentError" do
        assert_raises ArgumentError do
          with_oxen_routing do
            delete :destroy, :id => 123
          end
        end
      end
    end
  end
  private

  def with_oxen_routing
    with_routing do |map|
      map.draw do
        resources :oxen
      end
      yield
    end
    # GAH! with_routing actually clones @controller and then restores
    # the original later. Unfortunately this means that the assignment
    # to @controller.response is lost, and several shoulda tests rely
    # on that relationship rather than using @response directly. So
    # manually make the connection here.
    @controller.response = @response
  end
end

