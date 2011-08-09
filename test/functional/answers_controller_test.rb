require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  context "on index" do
    should "raise ActionController::RoutingError" do
      assert_raises ActionController::RoutingError do
        get :index
      end
    end
  end

  context "on a non-xhr request" do
    setup do
      answer = Factory :answer
      get :show, :id => answer.id
    end

    should redirect_to("root_url") { root_url }
  end

  should "be inlinified for all actions" do
    [ :show, :new, :create, :edit, :update, :destroy ].each do |action|
      assert @controller.respond_to?(action)
    end
  end

  context "the require_unpublished method" do
    should "raise an Argument exception if answer for published quiz is identified" do
      published_quiz = Factory :published_quiz
      question = Factory :question, :quiz_id => published_quiz.id
      answer = Factory :answer, :question_id => question.id
      stub(@controller).params { { :id => answer.id } }
      assert_raise ArgumentError do
        @controller.send(:require_unpublished)
      end
    end

    should "not raise an Argument exception if answer for unpublished quiz is identified" do
      unpublished_quiz = Factory :quiz
      question = Factory :question, :quiz_id => unpublished_quiz.id
      answer = Factory :answer, :question_id => question.id
      stub(@controller).params { { :id => answer.id } }
      assert_nothing_raised do
        @controller.send(:require_unpublished)
      end
    end
  end
end
