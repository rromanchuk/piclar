class UsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :html
  def home
    @feed_items = current_user.feed
    respond_with @feed_items
  end

  def show
    @user = User.find(params[:id])
  end

end