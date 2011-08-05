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
  context "the quiz method" do
    should "create and save! a quiz with the provided name" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz = Factory.build(:quiz)

      Quiz.expects(:new).with(:name => :quiz_name).returns(quiz)
      quiz.expects(:save!)

      quiz_constructor.quiz(:quiz_name) { }
    end

    should "set published to true" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz_constructor.quiz(:quiz_name) do
        assert quiz_constructor.instance_variable_get('@current_quiz').published
      end
    end

    should "yield with @current_quiz instance variable correctly set" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz = Factory.build(:quiz)

      Quiz.stubs(:new).with(:name => :quiz_name).returns(quiz)

      quiz_constructor.quiz(:quiz_name) do
        assert_equal quiz, quiz_constructor.instance_variable_get('@current_quiz')
      end
    end
  end

  context "the description method" do
    should "set the description for @current_quiz" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz = Factory.build(:quiz)
      quiz_constructor.instance_variable_set('@current_quiz', quiz)
      quiz.expects(:description=).with(:quiz_description)
      quiz_constructor.description(:quiz_description)
    end
  end

  context "the asks method" do
    should "create a Question for current quiz with provided text" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz = Factory.build(:quiz)
      quiz_constructor.instance_variable_set('@current_quiz', quiz)
      question = Factory.build(:question)

      Question.expects(:new).with(:text => :question_text).returns(question)
      quiz.questions.expects(:<<).with(question)

      quiz_constructor.asks(:question_text)
    end

    should "return a QuestionConstructor with new Question" do
      quiz_constructor = Object.new.extend QuizConstructor
      quiz = Factory.build(:quiz)
      quiz_constructor.instance_variable_set('@current_quiz', quiz)
      question = Factory.build(:question)

      Question.stubs(:new).with(:text => :question_text).returns(question)

      question_handler = quiz_constructor.asks(:question_text)

      assert_equal question, question_handler.instance_variable_get('@question')
      assert_equal QuizConstructor::QuestionConstructor, question_handler.class
    end
  end
end
