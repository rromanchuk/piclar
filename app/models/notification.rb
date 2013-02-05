class Notification < ActiveRecord::Base
  has_one :sender, :class_name => "User", :foreign_key => "sender_id"
  has_one :receiver, :class_name => "User", :foreign_key => "receiver_id"

  NOTIFICATION_TYPE_NEW_COMMENT = 1
  NOTIFICATION_TYPE_NEW_FRIEND = 2

  validates_inclusion_of :notification_type, :in => [NOTIFICATION_TYPE_NEW_COMMENT, NOTIFICATION_TYPE_NEW_FRIEND]

  attr_accessible :sender, :receiver, :notification_type
  
  def self.did_friend_user(current_user, other_user)
    Notification.create!(sender: current_user, receiver: other_user, notification_type: NOTIFICATION_TYPE_NEW_FRIEND)
  end

  def self.user_did_post
    Notification.create!(sender: User.first, receiver: User.first)
  end

end