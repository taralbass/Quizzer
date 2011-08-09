require 'test_helper'

# This require is needed due to an apparent bug in Rails autoloading.
# Essentially, it seems that the unit tests under quiz_constructor/*,
# which are namespaced within QuizConstructor, cause the module to be
# defined without properly loading the actual QuizConstructor module
# in lib/quiz_constructor.rb. This in turn means that instance methods
# defined there raise NoMethodError. Requiring the module causes it to
# be loaded correctly.
require 'quiz_constructor'

class QuizConstructorTest < ActiveSupport::TestCase
  include QuizConstructor

  context "the quiz method" do
    should "create and save! a quiz with the provided name" do
      quiz_name = Factory.attributes_for(:quiz)[:name]

      assert_difference 'Quiz.count' do
        quiz(quiz_name) { }
      end
    end

    should "set published to true" do
      quiz_name = Factory.attributes_for(:quiz)[:name]

      quiz(quiz_name) do
        assert_true @current_quiz.published
      end
    end

    should "yield with @current_quiz instance variable correctly set" do
      quiz_name = Factory.attributes_for(:quiz)[:name]

      quiz(quiz_name) do
        assert_equal quiz_name, @current_quiz.name
      end
    end
  end

  context "the description method" do
    should "set the description for @current_quiz" do
      quiz_name, quiz_description = Factory.attributes_for(:quiz).values_at(:name, :description)

      quiz(quiz_name) do
        description(quiz_description)
        assert_equal quiz_description, @current_quiz.description
      end
    end
  end

  context "the asks method" do
    should "create a Question for current quiz with provided text" do
      quiz_name = Factory.attributes_for(:quiz)[:name]
      question_text = Factory.attributes_for(:question)[:text]

      assert_difference 'Question.count' do
        quiz(quiz_name) do
          asks(question_text)
          assert_equal question_text, @current_quiz.questions.last.text
        end
      end

    end

    should "return a QuestionConstructor with new Question" do
      quiz_name = Factory.attributes_for(:quiz)[:name]
      question_text = Factory.attributes_for(:question)[:text]

      quiz(quiz_name) do
        assert_true asks(question_text).instance_of?(QuizConstructor::QuestionConstructor)
      end
    end
  end
end
