object @user
attributes :id, :vk_token, :fb_token, :authentication_token, :updated_at, :first_name, :last_name, :location, :birthday, :gender, :email

node :photo_url do |u|
  @user.photo.url(:thumb)
end