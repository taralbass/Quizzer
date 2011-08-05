class Evaluation < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :parent, :class_name => "Evaluation"
  has_many :results, :dependent => :destroy, :inverse_of => :evaluation
  accepts_nested_attributes_for :results

  attr_accessible :quiz_id, :parent_id, :completed, :results_attributes
  attr_readonly :quiz_id, :parent_id

  validates :quiz_id, :presence => true
  validates :completed, :inclusion => { :in => [ true, false ] }

  def question id
    quiz.questions.find(id)
  end

  def add_result question_id, result
    results.create :question_id => question_id, :result => result
  end

  def question_ids
    (parent ? parent.results.incorrect.collect(&:question_id) : quiz.questions.collect(&:id)) - results.collect(&:question_id)
  end

  def randomized_question_ids
    question_ids.shuffle
  end
end
