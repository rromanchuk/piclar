object @notification
attributes :id, :is_read, :created_at, :is_active, :notification_type

child :sender do 
  extends "users/show"
end