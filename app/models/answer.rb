class Answer < ActiveRecord::Base
  belongs_to :question

  attr_accessible :question_id, :text
  attr_readonly :question_id

  validates :question, :presence => true
  validates :text, :presence => true, :length => { :maximum => 50 }, :uniqueness => { :scope => :question_id }
end
