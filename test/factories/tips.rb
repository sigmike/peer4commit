# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tip do
    association :user
    amount 2
    commit { Digest::SHA1.hexdigest(SecureRandom.hex) }

    factory :undecided_tip do
      amount nil
    end
  end
end
