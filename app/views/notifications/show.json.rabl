object @notification
attributes :id, :is_read, :created_at, :is_active, :notification_type

node :sender do |notification|
  partial("users/show", :object => notification.sender) 
end

