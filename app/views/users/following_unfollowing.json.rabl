object @user
extends "users/show"

node :followers do |feed_item|
  feed_item.comments.map do |comment| 
    partial("comments/show", :object => comment) 
  end
end

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