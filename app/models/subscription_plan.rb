class SubscriptionPlan < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :interval_cd, presence: true, numericality: true
  validates :interval_count, presence: true, numericality: true

  has_many :subscriptions
  has_many :invoices, through: :subscriptions
  
  as_enum :interval, year: 0, month: 1

  def create_chart_mogul_plan
    ChartMogulService::Plan.delay.dispatch_create(subscription_plan: self)
  end

  def update_chart_mogul_plan_name
    ChartMogulService::Plan.delay.dispatch_update(subscription_plan: self)
  end
end
