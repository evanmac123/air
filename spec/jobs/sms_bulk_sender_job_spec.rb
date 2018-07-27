require 'rails_helper'

RSpec.describe SmsBulkSenderJob, type: :job do

  it "executes a SmsSenderJob for each user" do
    demo = FactoryBot.create(:demo, phone_number: "+12223334444")

    user_1 = FactoryBot.create(:user, demo: demo, email: "user_1@airbo.com", phone_number: "+11111111111")
    user_2 = FactoryBot.create(:user, demo: demo, email: "user_2@airbo.com", phone_number: "+12222222222")


    SmsSenderJob.expects(:perform_now).with(to_number: user_1.phone_number, body: "body")
    SmsSenderJob.expects(:perform_now).with(to_number: user_2.phone_number, body: "body")

    SmsBulkSenderJob.perform_now(user_ids: User.pluck(:id), body: "body")
  end
end
