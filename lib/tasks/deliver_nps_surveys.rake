desc "Delivers NPS survey to paid client admin every month"
task deliver_nps_surveys: :environment do
  if Date.current == Date.current.beginning_of_month
    Integrations::NetPromoterScore.send_survey_to_all_paid_client_admin
  end
end
