class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed_item

  attr_accessible :feed_item
end