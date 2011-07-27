class EvaluationsController < ApplicationController
  before_filter :require_xhr, :only => [ :pose_question, :compare_answers ]

  def show
    @evaluation = Evaluation.find(params[:id])
  end

  def new
    @evaluation = Evaluation.new(params[:evaluation])
  end

  def create
    evaluation = Evaluation.new(params[:evaluation])
    if evaluation.save
      redirect_to edit_evaluation_url(evaluation)
    else
      redirect_to root_url
    end
  end

  def edit
    @evaluation = Evaluation.find(params[:id], :include => { :quiz => :questions })
    @question_ids = @evaluation.randomized_question_ids
  end

  def update
    evaluation = Evaluation.find(params[:id])
    evaluation.update_attributes!(params[:evaluation])
    if request.xhr?
      render :nothing => true
    else
      redirect_to evaluation
    end
  end

  def pose_question
    @evaluation = Evaluation.find(params[:id])
    @question = @evaluation.quiz.questions.find(params[:question_id])
  end

  def compare_answers
    @evaluation = Evaluation.find(params[:id])
    @question = @evaluation.question(params[:question_id])

    if @question.correct_answers? *params[:answers].values
      @evaluation.add_result @question.id, "correct"
      @partial = 'matched_answers'
    else
      @partial = 'mismatched_answers'
    end
  end
end
