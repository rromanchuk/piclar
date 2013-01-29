class FeedItem < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  
  default_scope order: 'feed_items.created_at DESC'

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end

end