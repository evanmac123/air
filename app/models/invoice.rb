class Invoice < ActiveRecord::Base
  # attrs :amount_in_cents, :description, :due_date, :service_period_end, :service_period_start, :type_cd

  belongs_to :subscription
  has_many   :invoice_transactions

  validates :subscription, presence: true
  validates :amount_in_cents, presence: true, numericality: true
  validates :service_period_start, presence: true
  validates :service_period_end, presence: true
  validates :type_cd, presence: true

  as_enum :type, subscription: 0, one_time: 1

  def self.paid_invoices

  end

  def create_subscription_invoice_in_chart_mogul
    ChartMogulService::Invoice.create_subscription_invoice(invoice: self)
  end

  def organization
    subscription.organization
  end

  def subscription_id
    subscription.id
  end

  def subscription_plan
    subscription.subscription_plan
  end

 #METHODS FOR MIGRATION
  def self.subscription_cancelled?(contract, last_contract)
    if last_contract && contract.end_date < Date.today
      contract.end_date.end_of_day
    end
  end

  def self.match_new_plan(old_plan, cycle)
    if old_plan == "Engage"
      if cycle == "Annual"
        SubscriptionPlan.find_by_name("engage_annual")
      elsif cycle == "Monthly"
        SubscriptionPlan.find_by_name("engage_monthly")
      else
        SubscriptionPlan.find_by_name("engage_campaign")
      end
    elsif old_plan == "Activate"
      if cycle == "Monthly"
        SubscriptionPlan.find_by_name("activate_monthly")
      else
        SubscriptionPlan.find_by_name("activate_annual")
      end
    elsif old_plan == "Enterprise"
      SubscriptionPlan.find_by_name("enterprise")
    end
  end

  def self.add_invoices_from_org(org)
    ordered_contracts = org.contracts.order(:end_date).group_by {|c| c.plan}

    ordered_contracts.each do |plan, contracts|
      new_plan = Invoice.match_new_plan(plan, contracts.first.cycle)

      subscription = org.subscriptions.create(subscription_plan: new_plan)

      contracts.each_with_index do |contract, i|
        puts "ADDING INVOICES FOR #{subscription.organization.name}."
        if contracts.length - 1 == i
          last_contract = true
        else
          last_contract = false
        end

        subscription.invoices.create(
          due_date: contract.start_date.beginning_of_day,
          service_period_start: contract.start_date.beginning_of_day,
          service_period_end: contract.end_date.end_of_day,
          amount_in_cents: contract.amt_booked * 100,
          description: contract.notes,
          type_cd: 0
        )

        if Invoice.subscription_cancelled?(contract, last_contract)
          subscription.update_attributes(cancelled_at: Invoice.subscription_cancelled?(contract, last_contract))
        end
      end
    end
  end
end
