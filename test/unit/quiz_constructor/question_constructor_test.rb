require 'test_helper'

module QuizConstructor
  class QuestionConstructorTest < ActiveSupport::TestCase
    context "an QuestionConstructor instance" do
      should "assign argument to instance variable @question" do
        assert_equal :question_text, QuestionConstructor.new(:question_text).instance_variable_get('@question')
      end
    end

    context "invoking with_answer" do
      should "creates and adds one Answer with provided text" do
        question_constructor = QuestionConstructor.new(question = Factory.build(:question))
        answer = Factory.build(:answer)

        Answer.expects(:new).with(:text => :answer_text).returns(answer)
        question.answers.expects(:<<).with(answer)

        question_constructor.with_answer(:answer_text)
      end
    end

    context "invoking with_answers" do
      should "creates and add multiple Answers with provided text" do
        pairs = {}
        3.times { |i| pairs[:"answer_text_#{i}"] = Factory.build(:answer) }
        question_constructor = QuestionConstructor.new(question = Factory.build(:question))

        pairs.each do |text, object|
          Answer.expects(:new).with(:text => text).returns(object)
          question.answers.expects(:<<).with(object)
        end

        question_constructor.with_answers(*pairs.keys)
      end
    end
  end
end
