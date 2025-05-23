class User < ApplicationRecord
  include InvitationCodeValidator
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]
  after_create :send_welcome_email
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :invitation_code, presence: true
  validate :valid_invitation_code

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_many :dislikes, dependent: :destroy
  has_many :disliked_posts, through: :dislikes, source: :post

  def self.from_omniauth(auth)
    # Convert string keys to symbols if auth is a Hash
    auth = auth.with_indifferent_access if auth.is_a?(Hash)

    where(provider: auth[:provider], uid: auth[:uid]).first_or_create do |user|
      user.email = auth.dig(:info, :email)
      user.password = Devise.friendly_token[0, 20]
      user.username = auth.dig(:info, :name)
    end
  end

  def follow(other_user)
    following << other_user unless self == other_user || following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private
  def valid_invitation_code
    unless invitation_code == ENV["SITE_INVITATION_CODE"]
      errors.add(:invitation_code, "is not valid")
    end
  end

  def send_welcome_email
    # UserMailer.with(user: self).welcome_email.deliver_now
  end
end
