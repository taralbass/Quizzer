class Quiz < ActiveRecord::Base
  has_many :questions, :dependent => :destroy, :inverse_of => :quiz
  has_many :evaluations

  attr_accessible :name, :description
  attr_readonly :published  # don't make accessible!

  default_scope :order => :name

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 60 }
  validates :description, :length => { :maximum => 240 }
  validates :published, :inclusion => { :in => [ true, false ] }

  scope :published, where(:published => true)
  scope :unpublished, where(:published => false)

  def initialize_copy(original)
    super
    questions << original.questions.collect(&:clone).each { |q| q.quiz_id = nil }
  end
end
