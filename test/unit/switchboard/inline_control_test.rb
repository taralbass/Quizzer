require 'test_helper'

module Switchboard
  class InlineControlTest < ActiveSupport::TestCase
    setup do
      # anonymous Ox and OxenController classes to avoid cluttering namespace
      @anonymous_ox_class = Class.new do
        def self.name; "Ox"; end
        def self.find; end
        def self.accessible_attributes; []; end

      end
      
      @anonymous_oxen_controller_class = Class.new(ActionController::Base) do
        def self.name; "OxenController"; end
      end
    end

    #
    # Class Methods
    #
    
    context "a class that includes InlineControl" do
      setup do
        @anonymous_oxen_controller_class.send :include, Switchboard::InlineControl
        stub(@anonymous_oxen_controller_class).default_target_class { @anonymous_ox_class }
      end

      context "invoking the inlinify! method" do
        setup do
          @anonymous_oxen_controller_class.send :inlinify!
        end

        should "set target_class to the result of default_target_class" do
          assert_equal @anonymous_ox_class, @anonymous_oxen_controller_class.target_class
        end

        should "set target_symbol to the correct default symbol" do
          assert_equal :ox, @anonymous_oxen_controller_class.target_symbol
        end

        should "set show_partial class to the correct default show partial" do
          assert_equal 'oxen/ox', @anonymous_oxen_controller_class.show_partial
        end

        should "set new_partial to the correct default new partial" do
          assert_equal 'oxen/new', @anonymous_oxen_controller_class.new_partial
        end
      end

      context "invoking the inlinify! method after setting a configuration" do
        should "respect a target_class configuration for all configurations" do
          anonymous_horse_class = Class.new do
            def self.name; "Horse"; end
          end
          @anonymous_oxen_controller_class.send :inlinified_target_class, anonymous_horse_class
          @anonymous_oxen_controller_class.send :inlinify!
          assert_equal anonymous_horse_class, @anonymous_oxen_controller_class.target_class
          assert_equal :horse, @anonymous_oxen_controller_class.target_symbol
          assert_equal 'horses/horse', @anonymous_oxen_controller_class.show_partial
          assert_equal 'horses/new', @anonymous_oxen_controller_class.new_partial
        end

        should "respect a target_symbol configuration" do
          @anonymous_oxen_controller_class.send :inlinified_target_symbol, :foo
          @anonymous_oxen_controller_class.send :inlinify!
          assert_equal :foo, @anonymous_oxen_controller_class.target_symbol
        end

        should "respect a show_partial configuration" do
          @anonymous_oxen_controller_class.send :inlinified_show_partial, :foo
          @anonymous_oxen_controller_class.send :inlinify!
          assert_equal :foo, @anonymous_oxen_controller_class.show_partial
        end

        should "respect a new_partial configuration" do
          @anonymous_oxen_controller_class.send :inlinified_new_partial, :foo
          @anonymous_oxen_controller_class.send :inlinify!
          assert_equal :foo, @anonymous_oxen_controller_class.new_partial
        end
      end

      context "invoking inlinify! with no arguments" do
        setup do
          @anonymous_oxen_controller_class.inlinify!
        end

        should "inlinify all six actions" do
          assert @anonymous_oxen_controller_class.method_defined?(:show)
          assert @anonymous_oxen_controller_class.method_defined?(:new)
          assert @anonymous_oxen_controller_class.method_defined?(:create)
          assert @anonymous_oxen_controller_class.method_defined?(:edit)
          assert @anonymous_oxen_controller_class.method_defined?(:update)
          assert @anonymous_oxen_controller_class.method_defined?(:destroy)
        end
      end

      context "invoking inlinify! with list of actions" do
        setup do
          @anonymous_oxen_controller_class.inlinify! :edit, :update
        end
        
        should "inlinify only specified actions" do
          assert !@anonymous_oxen_controller_class.method_defined?(:show)
          assert !@anonymous_oxen_controller_class.method_defined?(:new)
          assert !@anonymous_oxen_controller_class.method_defined?(:create)
          assert @anonymous_oxen_controller_class.method_defined?(:edit)
          assert @anonymous_oxen_controller_class.method_defined?(:update)
          assert !@anonymous_oxen_controller_class.method_defined?(:destroy)
        end
      end
    end

    context "the InlineControl default_target_class method" do
      should "correctly determine default target class" do
        @anonymous_oxen_controller_class.send :include, Switchboard::InlineControl
        stub(ActiveSupport::Inflector).constantize("Ox") { @anonymous_ox_class }
        assert_equal @anonymous_ox_class, @anonymous_oxen_controller_class.send(:default_target_class)
      end
    end


    #
    # Instance Methods
    #
    context "an instance of an class including InlineControl" do
      setup do
        @anonymous_oxen_controller_class.send :include, Switchboard::InlineControl
        @anonymous_oxen_controller_class.send :inlinified_target_class, @anonymous_ox_class
        @anonymous_oxen_controller_class.send :inlinify!
        @controller_instance = @anonymous_oxen_controller_class.new
      end

      context "invoking the target_by_param_id instance method" do
        setup do
          stub(@controller_instance).params { { :id => :some_id } }
        end

        should "return the record identified by :id in params" do
          stub(@anonymous_ox_class).find(:some_id) { :an_ox }
          assert_equal :an_ox, @controller_instance.send(:target_by_param_id)
        end

        should "cache its result" do
          mock(@anonymous_ox_class).find(:some_id).times(1) { :an_ox }
          assert_equal @controller_instance.send(:target_by_param_id), @controller_instance.send(:target_by_param_id)
        end
      end

      context "invoking the attr instance method" do
        context "with an :attr parameter" do
          setup do
            stub(@controller_instance).params { { :attr => :some_attribute } }
          end

          should "return the attribute identified by :attr in params" do
            stub(@anonymous_ox_class).accessible_attributes { [ :some_attribute ] }
            assert_equal :some_attribute, @controller_instance.send(:attr)
          end

          should "throw an exception if the attribute is not accessible" do
            stub(@anonymous_ox_class).accessible_attributes { [] }
            assert_raise ArgumentError do
              @controller_instance.send(:attr)
            end
          end

          should "cache its result" do
            stub(@anonymous_ox_class).accessible_attributes.times(1) { [ :some_attribute ] }
            assert_equal @controller_instance.send(:attr), @controller_instance.send(:attr)
          end
        end

        context "without an :attr parameter" do
          setup do
            stub(@controller_instance).params { {} }
          end

          should "return nil" do
            assert_nil @controller_instance.send(:attr)
          end
        end
      end

      context "invoking the attr! instance method" do
        context "with an :attr parameter" do
          setup do
            stub(@controller_instance).params { { :attr => :some_attribute } }
          end

          should "return the attribute identified by :attr in params" do
            stub(@anonymous_ox_class).accessible_attributes { [ :some_attribute ] }
            assert_equal :some_attribute, @controller_instance.send(:attr!)
          end
        end

        context "without an :attr parameter" do
          setup do
            stub(@controller_instance).params { {} }
          end

          should "raise an ArgumentException" do
            assert_raises ArgumentError do
              @controller_instance.send(:attr!)
            end
          end
        end
      end

      context "invoking the sanitize method" do
        should "replace \r\n with \n" do
          assert_equal "foo1\nfoo2\nfoo3", @controller_instance.send(:sanitize, "foo1\r\nfoo2\r\nfoo3")
        end

        should "replace \n\n with \n" do
          assert_equal "foo1\nfoo2\nfoo3", @controller_instance.send(:sanitize, "foo1\n\rfoo2\n\rfoo3")
        end

        should "replace \r with \n" do
          assert_equal "foo1\nfoo2\nfoo3", @controller_instance.send(:sanitize, "foo1\rfoo2\rfoo3")
        end
      end

      context "invoking the scrub_param_values" do
        setup do
          stub(@controller_instance).sanitize { "foo" }
        end

        should "sanitize hash values that are strings" do
          assert_equal({ :key1 => "foo" }, @controller_instance.send(:scrub_param_values, { :key1 => "foo1" }))
        end

        should "leave as is values that are symbols" do
          assert_equal({ :key1 => :foo1 }, @controller_instance.send(:scrub_param_values, { :key1 => :foo1 }))
        end

        should "sanitize all elements of hash values that are arrays" do
          assert_equal({ :key1 => [ "foo", "foo" ]}, @controller_instance.send(:scrub_param_values, { :key1 => [ "foo1", "foo2" ] }))
        end

        should "recursively scrub hash values that are hashes" do
          assert_equal({ :key1 => { :key2 => "foo" } }, @controller_instance.send(:scrub_param_values, { :key1 => { :key2 => "foo1" } }))
        end

        should "sanitize multiple hash values" do
          assert_equal({ :key1 => "foo", :key2 => "foo" }, @controller_instance.send(:scrub_param_values, { :key1 => "foo1", :key2 => "foo2" }))
        end
      end
      
      context "invoking the scrub_target_params!" do
        should "scrub the params hash for target" do
          @controller_instance.params = { :ox => { :name => "foo1" } }
          mock(@controller_instance).scrub_param_values({ :name => "foo1" }) { :something }
          @controller_instance.send(:scrub_target_params!)
          assert_equal({ :ox => :something }, @controller_instance.params)
        end
      end
    end
  end
end
