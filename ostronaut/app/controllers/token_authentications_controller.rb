# token_authentications_controller.rb
class TokenAuthenticationsController < ApplicationController 
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def create
    if params[:platform] == "facebook"
      facebook_user = FbGraph::User.fetch(params[:user_id], :access_token => params[:access_token])
      puts facebook_user.to_yaml
      puts facebook_user.location.name
      @user = User.find_by_fbuid(params[:user_id])
      if @user
        @user.update_user_from_fb_graph(facebook_user)
      else
         @user = User.create_user_from_fb_graph(facebook_user)
      end
    end
    
    @user.ensure_authentication_token!
    @user.save
    render :inline => Rabl::Renderer.new('users/show', @user, :view_path => 'app/views', :format => 'json').render
  end

  def destroy
    @user = User.criteria.id(params[:id]).first
    @user.authentication_token = nil
    @user.save
    redirect_to edit_user_registration_path(@user)
  end

end