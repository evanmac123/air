class PushMessage < ActiveRecord::Base
  STATES = [
    (SCHEDULED = "scheduled".freeze),
    (SENDING = "sending".freeze),
    (COMPLETED = "completed").freeze
  ]

  belongs_to :demo

  serialize :email_recipient_ids, Array
  serialize :sms_recipient_ids, Array

  def perform
    update_attributes(state: SENDING)

    if plain_text.present? || html_text.present?
      GenericMailer::BulkSender.new(email_recipient_ids, subject, plain_text, html_text).delay.send_bulk_mails
    end

    if sms_text.present?
      SMS.bulk_send_messages(sms_recipient_ids, sms_text)
    end

    update_attributes(state: COMPLETED)
  end

  def self.schedule(attributes_and_options)
    push_message = self.create!(attributes_and_options)
    Delayed::Job.enqueue(push_message, run_at: push_message.scheduled_for)
    push_message
  end

  def self.incomplete
    where("state != ?", COMPLETED)
  end

  def self.in_time_order
    order("scheduled_for ASC NULLS FIRST")  
  end
end
