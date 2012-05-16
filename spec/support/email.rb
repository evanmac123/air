require "email_spec"

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
end

# Dummy mailer with no distinguishing characteristics except that it happens
# to descend from ActionMailer::Base; thus, if this mailer behaves the way we 
# want, there's a good reason to expect that others will too.

class DummyMailer < ActionMailer::Base
  def make_me_a_sandwich(user_id)
    user = User.find(user_id)
    mail(to: [user.email, "snoopy@hengage.com"],
         subject: "Make me a sandwich",
         from: "H Engage <doodz@hengage.com>"
        ) do |format|
          format.text {"Make me a sandwich"}
          format.html {"<p>Make me a sandwich</p>"}
        end
  end
end


