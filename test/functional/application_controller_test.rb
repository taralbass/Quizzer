require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  context "an anonymous controller" do
    setup do
      anonymous_controller_class = Class.new ApplicationController do
        def self.name; "AnonymousController"; end
        def root; end
        def raise_not_found; raise ActiveRecord::RecordNotFound, "mock error"; end
      end

      @controller = anonymous_controller_class.new
      send(:setup_controller_request_and_response)
    end

    context "that raises an ActiveRecord::RecordNotFound" do
      setup do
        with_routing do |map|
          map.draw do
            get "anonymous/raise_not_found"
            root :to => "anonymous#root"
          end
          get :raise_not_found
        end
      end

      before_should "handle it with handle_record_not_found if type ActiveRecord::RecordNotFound" do
        mock.proxy(@controller).handle_record_not_found(anything)
      end
    end
  end

  context "the require_xhr method" do
    should "not redirect for an xhr request" do
      stub(request).xhr? { true }
      do_not_allow(@controller).redirect_to
      @controller.send(:require_xhr)
    end

    should "redirect to root_url with flash for a non-xhr request" do
      stub(request).xhr? { false }
      mock(@controller).redirect_to(root_url, hash_including(:notice => GENERIC_ERROR_MESSAGE))
      @controller.send(:require_xhr)
    end
  end

  context "the handle_record_not_found method" do
    should "log an error and redirect to root_url with flash" do
      mock(@controller.logger).error(anything)
      mock(@controller).redirect_to(root_url, hash_including(:notice => NOT_FOUND_ERROR_MESSAGE))
      @controller.send(:handle_record_not_found, StandardError.new)
    end
  end
end
