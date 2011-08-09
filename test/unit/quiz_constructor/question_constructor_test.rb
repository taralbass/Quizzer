require 'test_helper'

module QuizConstructor
  class QuestionConstructorTest < ActiveSupport::TestCase
    context "an QuestionConstructor instance" do
      should "assign argument to instance variable @question" do
        assert_equal :question, QuestionConstructor.new(:question).instance_variable_get('@question')
      end
    end

    context "invoking with_answer" do
      should "builds and adds one Answer with provided text" do
        question = Factory.build(:question, :answers => [])
        question_constructor = QuestionConstructor.new(question)
        answer_text = Factory.attributes_for(:answer)[:text]

        question_constructor.with_answer(answer_text)
        assert_equal 1, question.answers.size
        assert_equal answer_text, question.answers.first.text
      end
    end

    context "invoking with_answers" do
      should "creates and add multiple Answers with provided text" do
        question = Factory.build(:question, :answers => [])
        question_constructor = QuestionConstructor.new(question)
        answer_texts = 3.times.collect { Factory.attributes_for(:answer)[:text] }
        question_constructor.with_answers(*answer_texts)
        assert_equal 3, question.answers.size
        assert_equal answer_texts, question.answers.collect(&:text)
      end
    end
  end
end
