# spec/factories/dislikes.rb
FactoryBot.define do
  factory :dislike do
    association :user
    association :post
  end
end
