task update_organizations: :environment do
  orgs = [["christina.orfanos@thementornetwork.com","02122",3],["cgordon@fujifilm.com","10195",7],["jmcnichol@asha.org","20850",10],["kkelly@rletech.com","80524",11],["ali.hodson@envisionitagency.com","60601",12],["pwilkinson@youthbuild.org","02144",15],["craig.byrd@merz.com","27615",16],["vwhatley@shoutfactory.com","90025",18],["emily@ampersand-health.com","37208",19],["yclark@accesssciences.com","77027",21],["sspates@mcpscorp.com","77384",22],["scolton@jpkeefehs.org","01702",23],["jthompson@aronsonllc.com","20850",24],["ataylor@epluscancercare.com","37205",26],["aanderson@constangy.com","30303",27],["chinn@coffman.com","91436",28],["lane.erwin@asco.org","22314",29],["laurel_parrish@ziffdavis.com","10016",30],["JCrick@altaregional.org","95815",31],["mjohnson@dedham-ma.gov","02026",32],["mdavis@natickps.org","01760",33],["monica.jerussi@willistowerswatson.com","10017",34],["sonya.woschenko@utc.com","06032",35],["lerxleben@probeninc.com","20708",291],["kandy@montridge.com","V6E2J3","371"],["apimpleton@wnj.com","49503",743],["cdoepker@keenan.com","90510",778],["rudy.r.garcia@qandun.com","91202",868],["abenning@viafield.com","50616",885],["lopsahl@mmm.com","55144",8],["psloane@abhct.com","06457",39],["ntemple@afcea.org","22033",13],["clower@antioch.edu","03431",14],["becky.rader@cnhind.com","60527",17],["tara.wilkins@willistowerswatson.com","75024",77],["rsiesser@heinekenusa.com","10601",283],["jandrade@houstonmethodist.org","77030",282],["ironbowtechnologies@ourairbo.com","20151",518],["tara.wilkins@willistowerswatson.com","94612",319],["pqtovar@leggmason.com","21202",338],["eachil@madisonlogic.com","10010",346],["jim.kohler@willistowerswatson.com","60523",113],["eplunkett@mgclinchey.com","70130",862],["david_convery@miltoncat.com","01757",20],["peggymoss@texashealth.org","76011",9],["gus.bentivegna@willistowerswatson.com","02199",663],["hdavid@vernoncollege.edu","76384",25]]

  Organization.update_all(chart_mogul_uuid: nil)
  orgs.each do |o|
    org = Organization.find(o[-1])
    org.zip_code = o[1]
    org.email = o[0]
    org.save
  end
end

task load_plan_data_into_chart_mogul: :environment do
  #PLANS
  a = SubscriptionPlan.create(name: "activate_monthly", interval_count: 1, interval_cd: 1)
  a.create_chart_mogul_plan

  aa = SubscriptionPlan.create(name: "activate_annual", interval_count: 1, interval_cd: 0)
  aa.create_chart_mogul_plan

  b = SubscriptionPlan.create(name: "engage_monthly", interval_count: 1, interval_cd: 1)
  b.create_chart_mogul_plan

  c = SubscriptionPlan.create(name: "engage_annual", interval_count: 1, interval_cd: 0)
  c.create_chart_mogul_plan

  d = SubscriptionPlan.create(name: "engage_campaign", interval_count: 1, interval_cd: 0)
  d.create_chart_mogul_plan

  e = SubscriptionPlan.create(name: "enterprise", interval_count: 1, interval_cd: 0)
  e.create_chart_mogul_plan
end

task load_customers_into_chart_mogul: :environment do
  #CUSTOMERS
  org_ids = Organization.joins(:contracts).uniq.pluck(:id)
  Organization.where(id: org_ids).where(chart_mogul_uuid: nil).each do |org|
    puts "ADDING #{org.name}."
    if org.name == "Montridge"
      country = "CA"
    else
      country = "US"
    end

    cm_org = ChartMogul::Customer.create!(
      data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
      external_id: org.id,
      name: org.name,
      email: org.email,
      country: country,
      zip: org.zip_code,
      lead_created_at: org.created_at
    )

    org.update_attribute(:chart_mogul_uuid, cm_org.uuid)
  end
end

task load_invoices_into_airbo: :environment do |t|

  #INVOICES
  org_ids = Organization.joins(:contracts).uniq.pluck(:id)
  Organization.where(id: org_ids).each do |org|
    unless org.id == 35 || org.id == 32
      Invoice.add_invoices_from_org(org)
    end
  end
end

task add_utc_invoices: :environment do |t|
  org = Organization.find(35)
  sub_1 = org.subscriptions.create(subscription_plan: SubscriptionPlan.find_by_name("engage_annual"))
  sub_2 = org.subscriptions.create(subscription_plan: SubscriptionPlan.find_by_name("engage_annual"))

  org.contracts.where(id: [47, 48, 273]).each do |contract|
    sub_1.invoices.create(
      due_date: contract.start_date.beginning_of_day,
      service_period_start: contract.start_date.beginning_of_day,
      service_period_end: contract.end_date.end_of_day,
      amount_in_cents: contract.amt_booked * 100,
      description: contract.notes,
      type_cd: 0
    )
  end

  org.contracts.where(id: [208]).each do |contract|
    sub_2.invoices.create(
      due_date: contract.start_date.beginning_of_day,
      service_period_start: contract.start_date.beginning_of_day,
      service_period_end: contract.end_date.end_of_day,
      amount_in_cents: contract.amt_booked * 100,
      description: contract.notes,
      type_cd: 0
    )
  end
end

task add_dedham_invoices: :environment do |t|
  org = Organization.find(32)
  sub_1 = org.subscriptions.create(subscription_plan: SubscriptionPlan.find_by_name("engage_annual"))
  sub_2 = org.subscriptions.create(subscription_plan: SubscriptionPlan.find_by_name("engage_annual"))

  org.contracts.where(id: [15, 16, 209]).each do |contract|
    sub_1.invoices.create(
      due_date: contract.start_date.beginning_of_day,
      service_period_start: contract.start_date.beginning_of_day,
      service_period_end: contract.end_date.end_of_day,
      amount_in_cents: contract.amt_booked * 100,
      description: contract.notes,
      type_cd: 0
    )
  end

  org.contracts.where(id: [17, 211]).each do |contract|
    sub_2.invoices.create(
      due_date: contract.start_date.beginning_of_day,
      service_period_start: contract.start_date.beginning_of_day,
      service_period_end: contract.end_date.end_of_day,
      amount_in_cents: contract.amt_booked * 100,
      description: contract.notes,
      type_cd: 0
    )
  end
end

task load_invoices_into_chart_mogul: :environment do |t|
  Invoice.where(chart_mogul_uuid: nil).each do |i|
    sleep 1
    i.create_subscription_invoice_in_chart_mogul
  end
end

task update_cancelled_chart_mogul_subscriptions: :environment do |t|
  Subscription.where("cancelled_at is not NULL").each do |internal_s|
    org = internal_s.organization
    org_subs = ChartMogul::Subscription.all(org.chart_mogul_uuid)
    cm_s = org_subs.subscriptions.find { |a| a.external_id.to_i == internal_s.id }
    internal_s.update_attributes(chart_mogul_uuid: cm_s.uuid)
    cm_s.cancel(internal_s.cancelled_at)
  end
end
