# encoding: utf-8
class FeedItem < ActiveRecord::Base
  has_many :comments
  has_many :likes

  belongs_to :user
  belongs_to :place

  default_scope order: 'feed_items.created_at DESC'

  attr_accessible :rating, :review, :is_active, :photo, :photo_attributes

  has_attached_file :photo,
    :storage => :s3,
    :bucket => CONFIG[:aws_bucket],
    :s3_credentials => {
      :access_key_id => CONFIG[:aws_access],
      :secret_access_key => CONFIG[:aws_secret]
    },
    :styles => { :standard => "640x640", :thumb => "196x196" },
    :path => "#{CONFIG[:aws_path]}/feed_items/:attachment/:id/:style/:basename.:extension",
    :s3_host_alias => CONFIG[:s3_cdn],
    :url => ':s3_alias_url'

  def fsq_client
    @client ||= Foursquare2::Client.new(:oauth_token => self.user.fsq_token)
  end

  def is_active
    true
  end

  def show_in_feed?(current_user)
    self.user.following?(current_user) || self.user == current_user
  end

  def me_liked?(current_user)
    self.likes.find_by_user_id(current_user).blank? ? false : true
  end

  def share_on_fsq!
    fsq_client.add_checkin(:venueId => self.place.foursquare_id, :broadcast => 'public', :ll => "#{self.place.latitude},#{self.place.longitude}", :shout => review)
  end

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

end