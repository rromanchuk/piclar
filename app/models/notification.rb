# encoding: utf-8
class Notification < ActiveRecord::Base
  has_one :sender, :class_name => "User", :foreign_key => "sender_id"
  has_one :receiver, :class_name => "User", :foreign_key => "receiver_id"

  NOTIFICATION_TYPE_NEW_COMMENT = 1
  NOTIFICATION_TYPE_NEW_FRIEND = 2

  validates_inclusion_of :notification_type, :in => [NOTIFICATION_TYPE_NEW_COMMENT, NOTIFICATION_TYPE_NEW_FRIEND]

  attr_accessible :sender, :receiver, :notification_type, :sender_id, :receiver_id

  def self.did_friend_user(current_user, other_user)
    Notification.create!(sender_id: current_user.id, receiver_id: other_user.id, notification_type: NOTIFICATION_TYPE_NEW_FRIEND)
    message = ""
    if current_user.gender == User::USER_SEX_FEMALE
      message = "#{current_user.name} добавила вас в друзья"
    else
      message = "#{current_user.name} добавил вас в друзья"
    end
    Notification.send_notfication!([other_user.id], message)
  end

  def self.user_did_post
    Notification.create!(sender: User.first, receiver: User.first)

  end

  def self.user_did_like(current_user, other_user, feed_item)
    if current_user.gender == User::USER_SEX_FEMALE
      message = "#{current_user.name} оценила вашу фотографию в #{feed_item.place.title}"
    else
      message = "#{current_user.name} оценил вашу фотографию в #{feed_item.place.title}"
    end
    
    Notification.send_notfication!([other_user.id], message, {type: 'notification_like', feed_item_id: feed_item.id, user_id: other.id})
  end

  def self.user_did_comment(current_user, comment)
    users_ids = comment.feed_item.comments.map {|c| c.user.id }
    message = ""
    if current_user.gender == User::USER_SEX_FEMALE
      message = "#{current_user.name} прокомментировала вашу фотографию"
    else
      message = "#{current_user.name} прокомментировал вашу фотографию"
    end

    Notification.send_notfication!(user_ids, message, {type: 'notification_comment', feed_item_id: comment.feed_item.id, user_id: current_user.id})
  end

  def self.send_notfication!(aliases, message, extra={})
    notification = { aliases: aliases, aps: {:alert => message, :badge => 1}, extra: extra }
    Urbanairship.push(notification)
  end



end