class Notification < ActiveRecord::Base
  has_one :sender  :class_name => "User", :foreign_key => "sender_id"
  has_one :receiver :class_name => "User", :foreign_key => "receiver_id"
end