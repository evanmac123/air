FactoryGirl.define do
  factory :organization  do
    sequence(:name) {|n| "Airbo Org #{n}" }

    trait :complete do
      sequence(:name){|n| "Client-#{n}"}
      num_employees   5000
    end

   trait :with_active_contract do
      after(:create) do |org, evaluator|
        create(:contract, :complete, :active, organization: org)
      end
   end

    trait :with_contracts do
      complete
      after(:create) do |org, evaluator|
        create(:contract, :complete, organization: org, start_date: '2012-01-01', end_date: '2012-12-31' )
        create(:contract, :complete, organization: org, start_date: '2013-01-01', end_date: '2013-12-31' )
        create(:contract, :complete, organization: org, start_date: '2014-01-01', end_date: '2014-12-31' )
      end
    end

  end

end
