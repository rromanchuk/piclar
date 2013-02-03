object @user
extends "users/show"

node :following do |user|
  user.followed_users.map do |user| 
    partial("users/show", :object => user) 
  end
end


node :followers do |user|
  user.followers.map do |user| 
    partial("users/show", :object => user) 
  end
end