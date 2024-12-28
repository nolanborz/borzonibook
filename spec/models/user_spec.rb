require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_invitation_code) { "test123" }

  before do
    allow(ENV).to receive(:[]).with("SITE_INVITATION_CODE").and_return(valid_invitation_code)
  end

  describe "factory" do
    it "has a valid factory" do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe "validations" do
    subject { build(:user) }

    context "username" do
      it { should validate_presence_of(:username) }
      it { should validate_uniqueness_of(:username).case_insensitive }
      it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }
    end

    context "email" do
      before { create(:user) }  # Create a user for uniqueness validation
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }

      it "validates email format" do
        user = build(:user, email: "invalid_email")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end
    end

    context "bio" do
      it { should validate_length_of(:bio).is_at_most(500) }

      it "allows blank bio" do
        user = build(:user, bio: "")
        expect(user).to be_valid
      end
    end

    context "invitation code" do
      it { should validate_presence_of(:invitation_code) }

      it "is valid with correct invitation code" do
        user = build(:user, invitation_code: valid_invitation_code)
        expect(user).to be_valid
      end

      it "is invalid with incorrect invitation code" do
        user = build(:user, invitation_code: "wrong_code")
        expect(user).not_to be_valid
        expect(user.errors[:invitation_code]).to include("is not valid")
      end
    end
  end

  describe "associations" do
    context "relationships" do
      it { should have_many(:active_relationships).dependent(:destroy) }
      it { should have_many(:passive_relationships).dependent(:destroy) }
      it { should have_many(:following).through(:active_relationships) }
      it { should have_many(:followers).through(:passive_relationships) }
    end

    context "content" do
      it { should have_many(:posts).dependent(:destroy) }
      it { should have_many(:comments).dependent(:destroy) }
    end

    context "interactions" do
      it { should have_many(:likes).dependent(:destroy) }
      it { should have_many(:liked_posts).through(:likes) }
      it { should have_many(:dislikes).dependent(:destroy) }
      it { should have_many(:disliked_posts).through(:dislikes) }
    end
  end

  describe "following methods" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe "#follow" do
      it "follows another user successfully" do
        expect { user.follow(other_user) }.to change { user.following.count }.by(1)
        expect(user.following?(other_user)).to be true
      end

      it "prevents self-following" do
        expect { user.follow(user) }.not_to change { user.following.count }
        expect(user.following?(user)).to be false
      end

      it "prevents duplicate following" do
        user.follow(other_user)
        expect { user.follow(other_user) }.not_to change { user.following.count }
        expect(user.following.count).to eq(1)
      end
    end

    describe "#unfollow" do
      before { user.follow(other_user) }

      it "unfollows successfully" do
        expect { user.unfollow(other_user) }.to change { user.following.count }.by(-1)
        expect(user.following?(other_user)).to be false
      end
    end
  end

  describe "omniauth" do
    let(:auth_hash) do
      {
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "test@example.com",
          name: "Test User"
        }
      }.with_indifferent_access
    end

    it "creates a new user from Google OAuth" do
      expect {
        user = User.from_omniauth(auth_hash)
        user.invitation_code = valid_invitation_code
        user.save!

        expect(user).to be_persisted
        expect(user.email).to eq("test@example.com")
        expect(user.username).to eq("Test User")
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456789")
      }.to change(User, :count).by(1)
    end

    it "finds existing user from Google OAuth" do
      existing_user = create(:user,
        email: "test@example.com",
        provider: "google_oauth2",
        uid: "123456789"
      )

      expect {
        user = User.from_omniauth(auth_hash)
        expect(user).to eq(existing_user)
      }.not_to change(User, :count)
    end
  end

  describe "callbacks" do
    describe "after_create" do
      it "sends welcome email" do
        # Uncomment when welcome email is implemented
        # expect { create(:user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
