object @feed_item
attributes :id, :me_liked, :is_active, :created_at, :updated_at

child :comments do
  extends "comments/show"
end

child :user do 
  extends "users/show"
end

