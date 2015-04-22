require 'acceptance/acceptance_helper'

feature "site admin sees list of bulk upload errors" do
  include BulkLoad::BulkLoadRedisKeys

  let(:object_key) {'a_fake_file.csv'}
  let(:redis) {Redis.new}

  it "should display the list of bulk upload errors" do
    redis.flushdb
    errors = 1.upto(10).map{|index| "Line #{index}: data was nonsensical"}
    errors.each {|error| redis.lpush(redis_failed_load_queue_key, error)}

    visit admin_bulk_upload_errors_path(object_key: object_key, as: an_admin)

    errors.each {|error| expect_content(error)}
  end
end
