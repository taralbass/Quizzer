require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  context "a Question instance" do
    should belong_to(:quiz)
    should have_many(:answers)
    should have_many(:results)

    should allow_mass_assignment_of(:quiz_id)
    should allow_mass_assignment_of(:text)
    should allow_mass_assignment_of(:answers_attributes)
    
    should have_readonly_attribute(:quiz_id)

    should validate_presence_of(:quiz)

    should validate_presence_of(:text)
    should ensure_length_of(:text).is_at_most(600)

    context "" do
      setup do
        Factory(:question)
      end
      should validate_uniqueness_of(:text).scoped_to(:quiz_id)
    end

    should "destroy its answers when it is destroyed" do
      question = Factory :question
      question.answers << answer = Factory(:answer)
      answer.expects(:destroy)
      question.destroy
    end

    should "have an inverted answers association" do
      question = Factory :question
      Factory :answer, :question_id => question.id

      question = Question.find(question.id, :include => :answers)
      same_question = question.answers.first.question
      question.text = "different text"
      assert_equal question.text, same_question.text
    end

    should "accept attributes for answers" do
      quiz = Factory :quiz, :questions => []
      question = quiz.questions.create(
                   Factory.attributes_for(:question).merge(
                     :answers_attributes => [ Factory.attributes_for(:answer) ]
                   )
                 )
      assert quiz.questions.first.answers.count > 0
    end

    should "make a deep clone" do
      question = Factory :question
      answer = Factory :answer, :question_id => question.id
      new_question = question.clone
      new_question.text += ' (copy)'
      new_question.save!
      assert_equal question.answers.collect(&:text), new_question.answers.collect(&:text)
      assert_not_equal question.answers.collect(&:id), new_question.answers.collect(&:id)
    end

    context "invoking correct_answers?" do
      setup do
        @question = Factory :question
      end

      context "with a single answer" do
        setup do
          @question.answers << Factory(:answer, :text => "abc")
        end

        should "return true if correct answer is provided" do
          assert @question.correct_answers?("abc")
        end

        should "return false if incorrect answer is provided" do
          assert !@question.correct_answers?("ab")
        end
      end

      context "with multiple answers" do
        setup do
          @question.answers << Factory(:answer, :text => "aaa")
          @question.answers << Factory(:answer, :text => "bbb")
          @question.answers << Factory(:answer, :text => "ccc")
        end

        should "return true if correct answers are provided" do
          assert @question.correct_answers?("bbb", "ccc", "aaa")
        end

        should "return false if incorrect answers are provided" do
          assert !@question.correct_answers?("bb", "cc")
        end
      end
    end
  end
end
