class Question < ActiveRecord::Base
  belongs_to :quiz
  has_many :answers, :dependent => :destroy, :inverse_of => :question
  has_many :results
  accepts_nested_attributes_for :answers

  attr_accessible :quiz_id, :text, :answers_attributes
  attr_readonly :quiz_id

  validates :quiz, :presence => true
  validates :text, :presence => true, :length => { :maximum => 600 }, :uniqueness => { :scope => :quiz_id }

  def initialize_copy(original)
    super
    answers << original.answers.collect(&:clone).each { |q| q.question_id = nil }
  end

  def correct_answers?(*provided_answers)
    answers.collect(&:text).sort == provided_answers.sort
  end
end
