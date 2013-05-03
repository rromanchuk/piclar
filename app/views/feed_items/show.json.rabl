object @feed_item
attributes :id, :is_active, :created_at, :updated_at, :rating, :review, :show_in_feed

child :user do
  extends "users/show"
end

child(:place, :if => lambda { |m| !m.place.blank? }) do 
  logger.error "in place render"
  extends "places/show" 
end

node :show_in_feed do |feed_item|
  feed_item.show_in_feed?(current_user)
end

node(:place_id, :if => lambda { |m| !m.place.blank? }) do |feed_item|
  feed_item.place.id
end

node :photo_url do |feed_item|
  feed_item.photo.url(:standard)
end

node :thumb_photo_url do |feed_item|
  feed_item.photo.url(:thumb)
end

node :me_liked do |feed_item|
  feed_item.me_liked?(current_user)
end


node :comments do |feed_item|
  feed_item.comments.map do |comment| 
    partial("comments/show", :object => comment) 
  end
end

node :likes do |feed_item|
  feed_item.likes.map do |like| 
    partial("users/show", :object => like.user) 
  end
end