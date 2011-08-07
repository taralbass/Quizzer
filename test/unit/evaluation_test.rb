require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase
  context "an Evaluation instance" do
    should belong_to(:quiz)
    should belong_to(:parent)
    should have_many(:results).dependent(:destroy)
    
    should allow_mass_assignment_of(:quiz_id)
    should allow_mass_assignment_of(:parent_id)
    should allow_mass_assignment_of(:completed)

    should have_readonly_attribute(:quiz_id)
    should have_readonly_attribute(:parent_id)

    should validate_presence_of(:quiz_id)
    should allow_value(true).for(:completed)
    should allow_value(false).for(:completed)

    should "accept attributes for results" do
      quiz = Factory :quiz
      question = Factory :question, :quiz_id => quiz.id
      evaluation = Evaluation.create!(
                     Factory.attributes_for(:evaluation).merge({
                       :quiz_id => quiz.id,
                       :results_attributes => [ Factory.attributes_for(:result, :question_id => question.id) ],
                     })
                   )
      assert evaluation.results.count > 0
    end

    context "invoking add_result" do
      should "create a new result" do
        evaluation = Factory :evaluation
        question = Factory :question
        evaluation.add_result question.id, 'correct'
        assert_equal question.id, evaluation.results.first.question_id
        assert_equal 'correct', evaluation.results.first.result
      end
    end

    context "invoking question_ids" do
      context "without a parent" do
        should "return question ids from quiz" do
          evaluation = Factory :evaluation
          questions = 3.times.collect { Factory :question, :quiz => evaluation.quiz }
          assert_equal questions.collect(&:id).sort, evaluation.question_ids
        end
      end

      context "with a parent" do
        should "return incorrect questions from parent" do
          evaluation = Factory :repeat_evaluation
          incorrect_results = 3.times.collect { Factory :incorrect_result, :evaluation => evaluation.parent }
          Factory :ignored_result, :evaluation => evaluation.parent
          Factory :correct_result, :evaluation => evaluation.parent
          assert_equal incorrect_results.collect(&:question_id).sort, evaluation.reload.question_ids.sort
        end
      end

      context "with existing results" do
        should "remove existing result questions from question ids" do
          evaluation = Factory :evaluation
          questions = 3.times.collect { Factory :question, :quiz => evaluation.quiz }
          question = questions.pop
          Factory :result, :evaluation_id => evaluation.id, :question_id => question.id
          assert_equal questions.collect(&:id).sort, evaluation.question_ids
        end
      end
    end

    context "invoking randomized_question_ids" do
      should "return randomized array of question ids" do
        evaluation = Evaluation.new
        results = [1, 2, 3, 4]
        results.expects(:shuffle).returns([2, 4, 3, 1])
        evaluation.stubs(:question_ids).returns(results)
        assert_equal [2, 4, 3, 1], evaluation.randomized_question_ids
      end
    end
  end
end
