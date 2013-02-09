class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    auth = request.env["omniauth.auth"]
    facebook_user =  FbGraph::User.fetch(auth.uid, :access_token => auth.credentials.token)
    @user = User.find_or_create_for_facebook_oauth(facebook_user, current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def vkontakte
    omniauth = request.env["omniauth.auth"]
   
  end

end
