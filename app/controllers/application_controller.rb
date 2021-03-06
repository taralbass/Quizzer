class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_record_not_found

  before_filter :ensure_domain if Rails.env.production?

  def about
  end

  private

  def require_xhr
    unless request.xhr?
      redirect_to root_url, :notice => GENERIC_ERROR_MESSAGE
    end
  end

  def handle_record_not_found(exception)
    logger.error "Attempted access to nonexistent record: #{exception.message}"
    redirect_to root_url, :notice => NOT_FOUND_ERROR_MESSAGE
  end

  def ensure_domain
    if request.host != SITE_DOMAIN
      redirect_to "http://#{SITE_DOMAIN}#{request.request_uri}", :status => 301
    end
  end
end
