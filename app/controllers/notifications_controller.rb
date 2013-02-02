class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
  
  def index
    @notifications = current_user.notifications
    respond_with @notifications
  end
  
  def mark_as_read
    current_user.read_all_notifications
  end

end