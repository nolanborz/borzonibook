class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  has_many :dislikes, dependent: :destroy
  has_many :dislikers, through: :dislikes, source: :user

  validates :content, presence: true

  def liked_by?(user)
    likes.where(user: user).exists?
  end

  def disliked_by?(user)
    dislikes.where(user: user).exists?
  end
end
