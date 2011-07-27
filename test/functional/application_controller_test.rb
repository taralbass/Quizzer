require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  context "when an ActiveRecord::RecordNotFound exception is raised" do
    setup do
      anonymous_controller_class = Class.new ApplicationController do
        def self.name; "AnonymousController"; end
        def root; end
        def index; raise ActiveRecord::RecordNotFound, "pretend I'm a real error"; end
      end

      @controller = anonymous_controller_class.new
      send(:setup_controller_request_and_response)

      with_routing do |map|
        map.draw do
          get "anonymous/index"
          root :to => "anonymous#root"
        end
        get :index
      end
    end

    should redirect_to("root_url") { root_url }
    should set_the_flash
    before_should "log an error message" do
      @controller.logger.expects(:error)
    end
  end

  context "the require_xhr method" do
    should "not redirect for an xhr request" do
      request.stubs(:xhr?).returns(true)
      @controller.expects(:redirect_to).never
      @controller.send(:require_xhr)
    end

    should "redirect to root_url with flash for a non-xhr request" do
      request.stubs(:xhr?).returns(false)
      @controller.expects(:redirect_to).with(root_url, has_key(:notice))
      @controller.send(:require_xhr)
    end
  end
end
