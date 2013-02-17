# encoding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:system_settings]
  respond_to :json, :html
  
  def home
    @feed_items = current_user.feed
    respond_with @feed_items
  end

  def show
    @user = User.find(params[:id])
  end

  def me
    @user = current_user
    render :show
  end

  def feed
   user = User.find(params[:id])
   @feed_items = user.feed
   render "feed_items/index"
  end

  def following_followers
    @user = current_user
  end

  def suggested
    @users = current_user.suggest_users
    render :index
  end

  def settings
    @user = current_user
    respond_with @user
  end

  def system_settings

  end

  def update_user
    @user = current_user
    @user.update_attributes(params[:user])
    render :show
  end

  def update_settings
    @user = current_user
    @user.update_attributes(params[:user])

    if params[:user][:vk_token]
      @vk = VkontakteApi::Client.new(params[:user][:vk_token])
      fields = [:first_name, :last_name, :screen_name, :bdate, :city, :country, :sex, :photo_big]
      vk_user = @vk.users.get(uid: params[:user_id], fields: fields).first
      vk_user.merge!(email: params[:email])
      @user = User.find_or_create_for_vkontakte_oauth(vk_user, params[:access_token])
    end
    render :show
  end

end