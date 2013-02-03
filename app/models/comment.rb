class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed_item

  attr_accessible :comment, :feed_item, :user

end