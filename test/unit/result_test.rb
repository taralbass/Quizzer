require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  context "a Result instance" do
    should belong_to(:evaluation)
    should belong_to(:question)

    should have_readonly_attribute(:evaluation_id)
    should have_readonly_attribute(:question_id)
    should have_readonly_attribute(:result)

    should validate_presence_of(:evaluation)
    should validate_presence_of(:question_id)

    should validate_uniqueness_of(:question_id).scoped_to(:evaluation_id)

    should validate_presence_of(:result)
    should allow_value('correct').for(:result)
    should allow_value('incorrect').for(:result)
    should allow_value('ignored').for(:result)
    should_not allow_value('foo').for(:result)

    should "not allow question to be from another quiz" do
      quiz1 = Factory :quiz
      question1 = Factory :question, :quiz_id => quiz1.id
      quiz2 = Factory :quiz
      evaluation = Factory :evaluation, :quiz_id => quiz2.id

      result = Result.create :evaluation_id => evaluation.id, :question_id => question1.id, :result => 'correct'
      assert result.errors[:question].size == 1
    end
  end
  
  context "the Result class" do
    context "invoking scopes" do
      setup do
        @incorrect_results = 2.times.collect { Factory :result, :result => 'incorrect' }
        @correct_results = 3.times.collect { Factory :result, :result => 'correct' }
        @ignored_results = [ Factory(:result, :result => 'ignored') ]
        @correct_results << Factory(:result, :result => 'correct')
      end

      should "return the correct results if correct scope is invoked" do
        assert_equal @correct_results.sort_by(&:id), Result.correct.sort_by(&:id)
      end

      should "return the incorrect results if incorrect scope is invoked" do
        assert_equal @incorrect_results.sort_by(&:id), Result.incorrect.sort_by(&:id)
      end

      should "return the ignored results if ignored scope is invoked" do
        assert_equal @ignored_results.sort_by(&:id), Result.ignored.sort_by(&:id)
      end
    end

  end

end
