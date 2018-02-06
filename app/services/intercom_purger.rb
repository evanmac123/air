# frozen_string_literal: true

class IntercomPurger
  def self.call(segment_id:)
    IntercomPurger.new(segment_id).perform
  end

  attr_reader :segment_id, :intercom_client

  def initialize(segment_id)
    @segment_id = segment_id
    @intercom_client = Intercom::Client.new(token: ENV["INTERCOM_ACCESS_TOKEN"])
  end

  def perform
    user_collection.each { |intercom_user| intercom_user.delete }
  end

  private

    def user_collection
      intercom_client.users.find_all(segment_id: @segment_id)
    end
end
