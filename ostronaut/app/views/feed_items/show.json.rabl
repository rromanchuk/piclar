object @feed_item
attributes :id, :is_active, :created_at, :updated_at, :rating, :review

child :user do 
  extends "users/show"
end

node :place_id do 
  @feed_item.place.id
end

node :comments do |feed_item|
  feed_item.comments.map do |comment| 
    partial("comments/show", :object => comment) 
  end
end