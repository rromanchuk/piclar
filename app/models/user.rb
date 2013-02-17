# encoding: utf-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :name, :provider, :fbuid, :birthday, :location, :fb_token, :photo, :city, :country, :gender, :vkuid, :vk_token
  attr_accessible :save_original, :save_filtered, :push_posts, :push_likes, :push_friends, :push_comments, :fsq_token

  USER_SEX_MALE = 1
  USER_SEX_FEMALE = 2
  USER_SEX_UNKNOWN = 0

  has_many :feed_items
  has_many :comments

  has_attached_file :photo,
    :storage => :s3,
    :bucket => CONFIG[:aws_bucket],
    :s3_credentials => {
      :access_key_id => CONFIG[:aws_access],
      :secret_access_key => CONFIG[:aws_secret]
    },
    :styles => { :thumb => "100x100>" },
    :path => "#{CONFIG[:aws_path]}/users/:attachment/:id/:style/:basename.:extension"

  has_many :followed_users, through: :relationships, source: :followed
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy

  has_many :notifications, foreign_key: "receiver_id", dependent: :destroy

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

   # the like associations
  has_many :likes
  has_many :liked_things, :through => :likes, :source => :feed_item

  after_create :find_and_follow_fb_friends, :find_and_follow_vk_friends
  
  def fb_client
     FbGraph::User.fetch(fbuid, :access_token => fb_token)
  end

  def vk_client
    VkontakteApi::Client.new(vk_token)
  end

  def vk_token
    self[:vk_token] || ""
  end

  def fb_token
    self[:fb_token] || ""
  end

  def name
    last_name + " " + first_name
  end

  def photo_from_url(url)
    self.photo = URI.parse(url)
    self.photo_file_name = "avatar.png"
    self.photo_content_type = "image/png"
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id) ? true : false
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def suggest_users
     already_following = self.followed_users.map(&:id)
     already_following << id
     User.where("id not in (?)", already_following)
  end

  def feed
    FeedItem.from_users_followed_by(self)
  end

  def update_user_from_vk_graph(vk_user, access_token)
    self.vk_token = access_token
  end

  def self.create_user_from_vk_graph(vk_user, access_token)
    user = User.create(
          :vkuid => vk_user.uid,
          :password => Devise.friendly_token[0,20],
          :first_name => vk_user.first_name,
          :last_name => vk_user.last_name,
          :birthday => vk_user.bdate,
          :city => get_vk_city(vk_user.city, access_token),
          :country => get_vk_country(vk_user.country, access_token),
          :vk_token => access_token,
          :gender => vk_user.sex,
          :provider => :vkontakte)
    user.photo_from_url vk_user.photo_big

    user
  end

  def update_user_from_fb_graph(facebook_user)
    self.fb_token = facebook_user.access_token
    self.first_name = facebook_user.first_name
    self.last_name = facebook_user.last_name
    self.birthday = facebook_user.birthday
    self.location = facebook_user.location.name unless facebook_user.location.blank?
    self.gender = (facebook_user.gender == "male") ? 1 : 2
    puts "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
    photo_from_url "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
    #photo_from_url "http://www.warrenphotographic.co.uk/photography/cats/21495.jpg"

    save
  end

  def self.create_user_from_fb_graph(facebook_user)
    user = User.create(:email => facebook_user.email,
          :fbuid => facebook_user.identifier,
          :password => Devise.friendly_token[0,20],
          :name => facebook_user.name,
          :first_name => facebook_user.first_name,
          :last_name => facebook_user.last_name,
          :birthday => facebook_user.birthday,
          :location => (facebook_user.location.blank?) ? "" : facebook_user.location.name,
          :fb_token => facebook_user.access_token,
          :provider => :facebook,
          :gender => (facebook_user.gender == "male") ? 2 : 0)
    user.photo_from_url "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
    return user
  end

  def self.find_or_create_for_vkontakte_oauth(vk_user, access_token)
    logger.debug vk_user.to_yaml
    if user = User.where(:vkuid => vk_user.uid).first
      user.update_user_from_vk_graph(vk_user, access_token)
      # User was created before. Just return him
    elsif user = User.find_by_email(vk_user.email)
      # User was created by parsing email. Add missing attrbute.
      user.update_user_from_vk_graph(vk_user, access_token)
      #UserMailer.activation(user).deliver rescue nil
    else
      user = User.create_user_from_vk_graph(vk_user, access_token)
    end
    user
  end

  def self.find_or_create_for_facebook_oauth(facebook_user, signed_in_resource=nil)
    logger.debug facebook_user.to_yaml
    if user = User.where(:fbuid => facebook_user.identifier).first
      user.update_user_from_fb_graph(facebook_user)
      # User was created before. Just return him
    elsif user = User.find_by_email(facebook_user.email)
      # User was created by parsing email. Add missing attrbute.
      user.update_user_from_fb_graph(facebook_user)
      #UserMailer.activation(user).deliver rescue nil
    else
      user = User.create_user_from_fb_graph(facebook_user)
    end

    user
  end

  def find_and_follow_fb_friends
    return if fb_token.blank?
    friends = fb_client.friends.map(&:identifier)
    users = User.where(:fbuid => friends)
    users.each do |user|
      follow!(user) if following?(user)
    end
  end

  def find_and_follow_vk_friends
    return if vk_token.blank?
    friends = vk_client.friends.get
    users = User.where(:vkuid => friends)
    users.each do |user|
      follow!(user) if following?(user)
    end
  end

  def read_all_notifications
    notifications.update_all(is_read: true)
  end

  def self.get_vk_city(id, token)
    HTTParty.get('https://api.vk.com/method/getCities', {query: {cids: id, access_token: token}})["response"].first["name"]
  end

  def self.get_vk_country(id, token)
    HTTParty.get('https://api.vk.com/method/getCountries', {query: {cids: id, access_token: token}})["response"].first["name"]
  end

  private

  def get_vk_city(id, token)
    User.get_vk_city(id, token)
  end

  def get_vk_country(id, token)
    User.get_vk_country(id, token)
  end
end