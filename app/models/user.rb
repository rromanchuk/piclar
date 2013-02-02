class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :name, :provider, :fbuid, :birthday, :location, :fb_token

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

  def vk_token
    self[:vk_token] || ""
  end

  def fb_token
    self[:fb_token] || ""
  end

  def photo_from_url(url)
    self.photo = URI.parse(url)
    self.photo_file_name == "avatar.png"
    self.photo_content_type == "image/png"
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def feed
    FeedItem.from_users_followed_by(self)
  end

  def update_user_from_fb_graph(facebook_user)
    self.fb_token = facebook_user.access_token
    self.first_name = facebook_user.first_name
    self.last_name = facebook_user.last_name
    self.birthday = facebook_user.birthday
    self.location = facebook_user.location.name unless facebook_user.location.blank?

    puts "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
    #photo_from_url "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
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
          :location => (facebook_user.location) ? facebook_user.location.name : "",
          :fb_token => facebook_user.access_token,
          :provider => :facebook)
    #user.photo_from_url "https://graph.facebook.com/#{facebook_user.identifier}/picture?width=100&height=100"
    return user
  end

  def self.find_or_create_for_facebook_oauth(auth, signed_in_resource=nil)
    logger.debug auth.to_yaml
    facebook_user = FbGraph::User.fetch(auth.uid, :access_token => auth.credentials.token)
    
    if user = User.where(:provider => auth.provider, :fbuid => auth.uid).first
      user.update_user_from_fb_graph(facebook_user)
      # User was created before. Just return him
    elsif user = User.find_by_email(auth.info.email)
      # User was created by parsing email. Add missing attrbute.
      user.update_user_from_fb_graph(facebook_user)
      #UserMailer.activation(user).deliver rescue nil
    else
      user = User.create_user_from_fb_graph(facebook_user)
    end

    user
  end

  def read_all_notifications
    notifications.update_all(:is_read, true)
  end




end