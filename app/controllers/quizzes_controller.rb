class QuizzesController < ApplicationController
  include Switchboard::InlineControl
  inlinify! :show, :edit, :update
  alias :inlinified_show :show

  skip_before_filter :inlinify_require_xhr
  before_filter :require_xhr, :only => [ :edit, :update ]
  before_filter :require_unpublished

  def index
    @manage = params[:manage_quizzes] || false
    @quizzes = @manage ? Quiz.unpublished : Quiz.published
  end

  def show
    if request.xhr?
      inlinified_show
    else
      @quiz = Quiz.find(params[:id])
    end
  end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.new(params[:quiz])

    if @quiz.save
      redirect_to @quiz
    else
      render :action => "new"
    end
  end

  def destroy
    Quiz.find(params[:id]).destroy
    redirect_to quizzes_url(:manage_quizzes => true), :notice => "Quiz deleted."
  end

  private

  # a fully developed version of quizzer would include authentication and quiz ownership
  # this serves as an alternate security scheme to protect "official" (published) quizzes
  # from modification in the quiz management demo
  def require_unpublished
    if params[:id]
      Quiz.find(params[:id]).published and raise ArgumentError, "can't manage a published quiz"
    end
  end

end
