class RelationshipsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)

    Notification.did_friend_user(current_user, @user)

    render "users/show"
  end

  def destroy
    @user = User.find(params[:id])
    current_user.unfollow!(@user)
    render "users/show"
  end

end
