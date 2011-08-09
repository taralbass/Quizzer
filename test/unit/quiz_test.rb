require 'test_helper'

class QuizTest < ActiveSupport::TestCase
  context "a Quiz instance" do
    should have_many(:questions).dependent(:destroy)
    should have_many(:evaluations)

    should allow_mass_assignment_of(:name)
    should allow_mass_assignment_of(:description)
    should_not allow_mass_assignment_of(:published)
    should have_readonly_attribute(:published)

    should validate_presence_of(:name)
    should ensure_length_of(:name).is_at_most(60)
    should validate_uniqueness_of(:name)

    should ensure_length_of(:description).is_at_most(240)

    should allow_value(true).for(:published)
    should allow_value(false).for(:published)

    should "have an inverted questions association" do
      quiz = Factory(:question).quiz
      quiz = Quiz.find(quiz.id, :include => :questions)
      same_quiz = quiz.questions.first.quiz
      quiz.name = "a different quiz name"
      assert_equal quiz.name, same_quiz.name
    end

    should "make a deep clone" do
      question = Factory :question
      quiz = question.quiz
      new_quiz = quiz.clone
      new_quiz.name += " (copy)"
      new_quiz.save!
      assert_equal quiz.questions.collect(&:text), new_quiz.questions.collect(&:text)
      assert_not_equal quiz.questions.collect(&:id), new_quiz.questions.collect(&:id)
    end
  end

  context "The Quiz class" do
    should "order results by name by default" do
      # although I don't like testing against SQL, the SQL feels more
      # ActiveRecord-implementation independent than examining the internals
      # of the Quiz.scoped relation. could alternatively build a test around
      # setting up a bunch of records and testing return order, but this is
      # heavy and also unideal as it starts testing ActiveRecord functionality
      # rather than that the default scope has been correctly set.
      assert Quiz.scoped.to_sql =~ /order by name/i, "Quiz results are not ordered by name"
    end

    context "invoking scopes" do
      setup do
        @published_quizzes = 2.times.collect { Factory :published_quiz }
        @unpublished_quizzes = 3.times.collect { Factory :quiz }
      end

      should "return the published quizzes if published scope is invoked" do
        assert_equal @published_quizzes.sort_by(&:id), Quiz.published.sort_by(&:id)
      end

      should "return the unpublished quizzes if unpublished scope is invoked" do
        assert_equal @unpublished_quizzes.sort_by(&:id), Quiz.unpublished.sort_by(&:id)
      end
    end
  end
end
