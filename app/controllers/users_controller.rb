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

  def follow
    @other_user = User.find(params[:id])
    current_user.follow! @other_user
    Notification.did_friend_user(current_user, @other_user)
  end

  def unfollow
    @other_user = User.find(params[:id])
    current_user.unfollow! @other_user
  end

  def following_followers
    @user = current_user
  end

  def suggested
    @users = current_user.suggest_users
  end

  def settings
    @user = current_user
    respond_with @user
  end

  def update_settings
    @user = current_user.update_attributes(params[:user])
    respond_with @user
  end

end