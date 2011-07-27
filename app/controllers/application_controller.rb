class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_record_not_found

  def about
  end

  private

  def require_xhr
    unless request.xhr?
      redirect_to root_url, :notice => "Sorry, your request cannot be completed."
    end
  end

  def handle_record_not_found exception
    logger.error "Attempted access to nonexistent record: #{exception.message}"
    redirect_to root_url, :notice => "Sorry, that record does not exist."
  end
end
