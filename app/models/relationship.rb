# encoding: utf-8
class Relationship < ActiveRecord::Base
  attr_accessible :followed_id

  belongs_to :follower, class_name: "User"

  validates :followed_id, presence: true
end
