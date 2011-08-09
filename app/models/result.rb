class Result < ActiveRecord::Base
  belongs_to :evaluation
  belongs_to :question

  attr_accessible :evaluation_id, :question_id, :result
  attr_readonly :evaluation_id, :question_id, :result

  validates :evaluation, :presence => true
  validates :question_id, :presence => true, :uniqueness => { :scope => :evaluation_id }
  validates :result, :presence => true, :inclusion => { :in => [ 'correct', 'incorrect', 'ignored' ] }
  validate :question_belongs_to_evaluation_quiz

  scope :correct, where(:result => 'correct')
  scope :incorrect, where(:result => 'incorrect')
  scope :ignored, where(:result => 'ignored')

  private

  def question_belongs_to_evaluation_quiz
    if question && evaluation && question.quiz_id != evaluation.quiz_id
      errors.add(:question, "must be from evaluation quiz")
    end
  end
end
