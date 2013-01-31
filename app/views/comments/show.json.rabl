object @comment
attributes :id, :comment, :created_at, :updated_at

child :user do 
  extends "users/show"
end