class PushMessage < ActiveRecord::Base
  STATES = [
    (SCHEDULED = "scheduled".freeze),
    (SENDING = "sending".freeze),
    (COMPLETED = "completed").freeze
  ]

  belongs_to :demo

  serialize :email_recipient_ids, Array
  serialize :sms_recipient_ids,   Array

  serialize :seq_query_columns,   Hash
  serialize :seq_query_operators, Hash
  serialize :seq_query_values,    Hash

  def perform
    update_attributes(state: SENDING)

    user_ids = User::Segmentation.load_segmented_user_information(seq_query_columns, seq_query_operators, seq_query_values, demo_id)
    users = User.where(:id => user_ids)

    if respect_notification_method?
      email_recipient_ids = users.wants_email.pluck(:id)
      sms_recipient_ids = users.wants_sms.with_phone_number.pluck(:id)
    else
      email_recipient_ids = sms_recipient_ids = user_ids
    end

    # Mailing list may have changed since job was created => Update list of recipients
    update_attributes email_recipient_ids: email_recipient_ids, sms_recipient_ids: sms_recipient_ids

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
