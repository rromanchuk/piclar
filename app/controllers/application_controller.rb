class ApplicationController < ActionController::Base
  protect_from_forgery
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # unless Rails.application.config.consider_all_requests_local
  #   rescue_from Exception,                            :with => :render_error
  #   rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
  #   rescue_from ActionController::RoutingError,       :with => :render_not_found
  #   rescue_from ActionController::UnknownController,  :with => :render_not_found
  #   rescue_from ActionController::UnknownAction,      :with => :render_not_found
  # end

  # private
  # def render_not_found(exception)
  #   render :template => 'error_pages/404', :layout => false, :status => 404
  # end

  # def render_error(exception)
  #   render :template => 'error_pages/505', :layout => false, :status => 500
  # end


end
