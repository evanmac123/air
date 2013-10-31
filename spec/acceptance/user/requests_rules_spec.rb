require 'acceptance/acceptance_helper'

feature "User Requests Rules"do
  scenario "User requests rules" do
    FactoryGirl.create :user, :phone_number => "+14155551212"

    mo_sms("+14155551212", "rules")
    expect_mt_sms("+14155551212",
                  %{CONNECT [someone's ID] - become connected (ex: "connection bob12")\nMYID - see your ID\nRANKING - see connections\nHELP - help desk, instructions\nPRIZES - see what you can win}
    )
  end
end
