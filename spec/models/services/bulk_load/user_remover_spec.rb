require 'spec_helper'

describe BulkLoad::UserRemover do
  include BulkLoad::BulkLoadRedisKeys
  
  before do
    Redis.new.flushdb
  end

  let(:employee_ids_to_keep) {%w(123 456 78910 1112131415)}
  let(:employee_ids_to_remove) {%w(0914 89185 109059 8918 0910950)}
  let(:object_key) {"some_file.csv"}
  let(:redis) {Redis.new}

  def load_employee_ids_to_keep_into_redis
    redis.sadd(redis_unique_id_queue_key, employee_ids_to_keep)
  end

  def expect_user_ids_in_queue_and_object(remover, user_ids_to_remove)
    remover.user_ids_to_remove.map(&:to_s).sort.should == user_ids_to_remove.map(&:to_s).sort
    ids_queued_to_remove = redis.smembers(remover.redis_user_ids_to_remove_key)
    user_ids_to_remove.map(&:to_s).sort.should == ids_queued_to_remove.map(&:to_s).sort
  end

  def predetermine_ids(ids_to_save, key)
    ids_to_save.each {|id| redis.sadd(key, id)}
  end

  def weird_user_prettyprinter(user_id)
    user = User.find(user_id)
    "I am #{user.name} number #{user_id}, of the tribe #{user.email}"
  end

  describe "#user_ids_to_remove" do
    def create_users_from_employee_ids(board, employee_ids)
      users = []
      employee_ids.each do |employee_id|
        users << FactoryGirl.create(:user, employee_id: employee_id, demo: board)
      end
      users
    end

    before do
      @board = FactoryGirl.create(:demo)
      @other_board = FactoryGirl.create(:demo)

      create_users_from_employee_ids(@board, employee_ids_to_keep) + create_users_from_employee_ids(@other_board, employee_ids_to_keep + employee_ids_to_remove)
      @users_to_remove = create_users_from_employee_ids(@board, employee_ids_to_remove)
    end
    
    context "when the set of user IDs has not yet been determined" do
      it "should determine the set of user IDs to delete and stick them in a queue" do
        load_employee_ids_to_keep_into_redis

        remover = BulkLoad::UserRemover.new(@board.id, object_key, :employee_id)
        expect_user_ids_in_queue_and_object(remover, @users_to_remove.map(&:id))
      end
    end

    context "when the set of user IDs has been determined" do
      it "should read it out of Redis" do
        remover = BulkLoad::UserRemover.new(@board.id, object_key, :employee_id)

        arbitrary_ids = [589, 89153, 599835]
        predetermine_ids(arbitrary_ids, redis_user_ids_to_remove_key)

        expect_user_ids_in_queue_and_object(remover, arbitrary_ids)
      end
    end
  end

  it "should exclude site admins" do
    board = FactoryGirl.create(:demo)
    user = FactoryGirl.create(:user, demo: board)
    user.is_site_admin = true
    user.save!

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    expect_user_ids_in_queue_and_object(remover, [])
  end

  it "should exclude anyone with a \"usual suspects\" email domain" do
    board = FactoryGirl.create(:demo)
    usual_suspect_emails = %w(jimmy@airbo.com jane.doe@towerswatson.com bob@air.bo frieda@hengage.com)
    usual_suspect_emails.each{|email| FactoryGirl.create(:user, email: email, demo: board)}

    guys_to_delete = FactoryGirl.create_list(:user, 2, demo: board)
    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    expect_user_ids_in_queue_and_object(remover, guys_to_delete.map(&:id))
  end

  it "should easily let you preview users by means of a block" do
    board = FactoryGirl.create(:demo)
    users = FactoryGirl.create_list(:user, 2, demo: board)

    predetermine_ids(users.map(&:id), redis_user_ids_to_remove_key)

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    
    result = []
    remover.preview do |user_id|
      result << weird_user_prettyprinter(user_id)
    end

    expected_result = users.map{|user| weird_user_prettyprinter(user.id)}.sort
    result.sort.should == expected_result
  end

  it "should easily let you remove a user from the set to be removed" do
    board = FactoryGirl.create(:demo)
    users = FactoryGirl.create_list(:user, 2, demo: board)

    predetermine_ids(users.map(&:id), redis_user_ids_to_remove_key)

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    expect_user_ids_in_queue_and_object(remover, users.map(&:id))

    user_to_keep = users.first
    user_to_remove = users.last
    remover.retain_user(user_to_keep.id)

    expect_user_ids_in_queue_and_object(remover, [user_to_remove.id])
  end

  it "should delete users in just the one board"
  it "should un-join users in multiple boards"
end
