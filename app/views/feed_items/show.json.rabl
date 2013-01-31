object @feed_item
attributes :id, :is_active, :created_at, :updated_at, :rating, :review

child :user do 
  extends "users/show"
end

child :place do
  extends "places/show"
end

node :place_id do |feed_item|
  feed_item.place.id
end

node :photo do 
  { :url => @feed_item.photo.url(:standard), :thumb_url => @feed_item.photo.url(:thumb) }
end

node :comments do |feed_item|
  feed_item.comments.map do |comment| 
    partial("comments/show", :object => comment) 
  end
end