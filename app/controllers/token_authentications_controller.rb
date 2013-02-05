# token_authentications_controller.rb
class TokenAuthenticationsController < ApplicationController 
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def create
    if params[:platform] == "facebook"
      facebook_user = FbGraph::User.fetch(params[:user_id], :access_token => params[:access_token])
      puts facebook_user.to_yaml
      puts facebook_user.location.name
      @user = User.find_or_create_for_facebook_oauth(facebook_user)
    elsif params[:platform] == "vkontakte"
      @vk = VkontakteApi::Client.new(params[:access_token])
      fields = [:first_name, :last_name, :screen_name, :bdate, :city, :country, :sex, :photo_big]
      vk_user = @vk.users.get(uid: params[:user_id], fields: fields).first
      vk_user.merge!(email: params[:email])
      @user = User.find_or_create_for_vkontakte_oauth(vk_user, params[:access_token])
    end
    
    @user.ensure_authentication_token!
    @user.save
    respond_with @user
  end

  def destroy
    @user = User.criteria.id(params[:id]).first
    @user.authentication_token = nil
    @user.save
    redirect_to edit_user_registration_path(@user)
  end

end