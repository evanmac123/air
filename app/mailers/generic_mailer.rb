class GenericMailer < ActionMailer::Base
  def send_message(user_id, subject, plain_text, html_text)
    user = User.find(user_id)

    from_string = user.demo.email.present? ? "#{user.demo.name} <#{user.demo.email}>" : "H Engage <play@playhengage.com>"

    mail(
      :to      => user.email,
      :subject => subject,
      :from    => from_string
    ) do |format|
      format.text {render :text => plain_text}
      format.html {render :text => html_text}
    end
  end

  module BulkSender
    def self.bulk_generic_messages(user_ids, subject, plain_text, html_text)
      user_ids.each do |user_id|
        GenericMailer.delay.send_message(user_id, subject, plain_text, html_text)
      end
    end
  end
end
