require 'acceptance/acceptance_helper'

feature 'site admin monitors bulk upload progress' do
  include BulkLoad::BulkLoadRedisKeys

  let(:redis)      {Redis.new}
  let(:object_key) {"fakefile.csv"}

  def set_fake_list(key, length)
    length.times { redis.lpush key, 'x' }
  end

  before do
    board = FactoryGirl.create(:demo)
    users = FactoryGirl.create_list(:user, 10)
    users.each{|user| user.add_board(board)}

    redis.flushdb
    set_fake_list(redis_load_queue_key, 167)
    set_fake_list(redis_failed_load_queue_key, 6)

    baseline_time = Time.now + 5.minutes
    Timecop.travel(10.minutes)
    updated_users = users.sort_by{|_u| rand}[0,7]
    updated_users.each{|user| user.update_column(:updated_at, Time.now)}

    Delayed::Job.all.each(&:destroy)
    3.times {nil.delay.nil?}
    Delayed::Job.last.update_column(:attempts, 5)

    visit admin_bulk_upload_progress_path(object_key: object_key, baseline_time: baseline_time.to_param, demo_id: board.id, as: an_admin)
  end

  after do
    Timecop.return
  end

  it 'should show load queue length' do
    expect_content "167 records in load queue"
  end

  it 'should show failed load queue length' do
    expect_content "6 records in failed load queue"
  end

  it 'should show number of users updated/not updated since baseline time' do
    expect_content "7 users updated since baseline time"
    expect_content "3 users not updated since baseline time"
  end

  it 'should show number of unprocessed delayed jobs' do
    expected_job_count = Delayed::Job.where(attempts: 0).count
    expect_content "#{expected_job_count} never-attempted delayed jobs in the queue"
  end

  it 'should link to a page where you can see the errors' do
    click_link "(see errors)"
    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}".should == admin_bulk_upload_errors_path(object_key: object_key)
  end
end
