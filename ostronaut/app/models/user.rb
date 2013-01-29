class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :name, :provider, :fbuid

  has_many :feed_items
  has_many :comments
  has_many :photos

  has_attached_file :photo, :styles => { :thumb => "100x100>" }

  has_many :followed_users, through: :relationships, source: :followed
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

   # the like associations
  has_many :likes
  has_many :liked_things, :through => :likes, :source => :feed_item

  


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


  def self.find_or_create_for_facebook_oauth(auth, signed_in_resource=nil)
    logger.debug auth.to_yaml
    if user = User.where(:provider => auth.provider, :fbuid => auth.uid).first
      # User was created before. Just return him
    elsif user = User.find_by_email(auth.info.email)
      # User was created by parsing email. Add missing attrbute.
      user.name = auth.extra.raw_info.name unless user.name
      user.provider = auth.provider unless user.provider
      user.fbuid = auth.uid
      user.password = Devise.friendly_token[0,20] unless user.encrypted_password
      user.save!
      #UserMailer.activation(user).deliver rescue nil
    else
      user = User.create!(
        name:     auth.extra.raw_info.name,
        provider: auth.provider,
        fbuid:      auth.uid,
        email:    auth.info.email,
        password: Devise.friendly_token[0,20]
        )
      #UserMailer.activation(user).deliver rescue nil
    end

    user
  end


end