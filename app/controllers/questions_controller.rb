class QuestionsController < ApplicationController
  include Switchboard::InlineControl
  inlinified_initialize_for_new_method :initialize_for_new
  inlinify!

  skip_before_filter :inlinify_require_xhr
  before_filter :require_xhr
  before_filter :require_unpublished

  private

  # a fully developed version of quizzer would include authentication and quiz ownership
  # this serves as an alternate security scheme to protect "official" (published) quizzes
  # from modification in the quiz management demo
  def require_unpublished
    if params[:id]
      Question.find(params[:id]).quiz.published and raise ArgumentError, "can't manage a published quiz"
    end
  end

  def initialize_for_new args=[]
    question = Question.new args
    question.answers << Answer.new
    question
  end
end
