task load_plans_into_chart_mogul: :environment do
  #PLANS
  SubscriptionPlan.create(name: "Activate", interval_count: 1, interval_unit_cd: 1)
  SubscriptionPlan.create(name: "Engage - Monthly", interval_count: 1, interval_unit_cd: 0)
  SubscriptionPlan.create(name: "Engage - Annual", interval_count: 1, interval_unit_cd: 1)
  SubscriptionPlan.create(name: "Engage - Campaign", interval_count: 1, interval_unit_cd: 0)
  SubscriptionPlan.create(name: "Enterprise", interval_count: 1, interval_unit_cd: 1)
end

# rake load_plans_into_chart_mogul
