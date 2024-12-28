# spec/factories/likes.rb
FactoryBot.define do
  factory :like do
    association :user
    association :post
  end
end
