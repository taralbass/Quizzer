require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  context "on index" do
    should "raise ActionController::RoutingError" do
      assert_raises ActionController::RoutingError do
        get :index
      end
    end
  end

  context "on a non-xhr request" do
    setup do
      @question = Factory :question
      get :show, :id => @question.id
    end

    should redirect_to("root_url") { root_url }
  end

  context "the initialize_for_new method" do
    should "create a blank answer for question" do
      question = @controller.send(:initialize_for_new)
      assert_equal 1, question.answers.size
    end
  end

  should "be inlinified for all actions" do
    [ :show, :new, :create, :edit, :update, :destroy ].each do |action|
      assert_true @controller.respond_to?(action)
    end
  end

  context "the require_unpublished method" do
    should "raise an Argument exception if question for published quiz is identified" do
      published_quiz = Factory :published_quiz
      question = Factory :question, :quiz_id => published_quiz.id
      stub(@controller).params { { :id => question.id } }
      assert_raise ArgumentError do
        @controller.send(:require_unpublished)
      end
    end

    should "not raise an Argument exception if question for unpublished quiz is identified" do
      unpublished_quiz = Factory :quiz
      question = Factory :question, :quiz_id => unpublished_quiz.id
      stub(@controller).params { { :id => question.id } }
      assert_nothing_raised do
        @controller.send(:require_unpublished)
      end
    end
  end
end
