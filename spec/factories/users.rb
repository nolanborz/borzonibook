# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 3..30) }
    email { Faker::Internet.email }
    password { "password123" }
    bio { Faker::Lorem.paragraph_by_chars(number: 300) }
    invitation_code { ENV["SITE_INVITATION_CODE"] }
    provider { nil }
    uid { nil }

    # Trait for Google OAuth users
    trait :google_user do
      provider { "google_oauth2" }
      uid { Faker::Number.number(digits: 21).to_s }
    end

    # Trait for users with maximum length bio
    trait :with_max_bio do
      bio { Faker::Lorem.paragraph_by_chars(number: 500) }
    end
  end
end
