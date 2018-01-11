require 'spec_helper'

describe BulkLoad::UserRemover do
  include BulkLoad::BulkLoadRedisKeys

  let(:employee_ids_to_keep) {%w(123 456 78910 1112131415)}
  let(:employee_ids_to_remove) {%w(0914 89185 109059 8918 0910950)}
  let(:object_key) {"some_file.csv"}

  def load_employee_ids_to_keep_into_redis
    $redis_bulk_upload.sadd(redis_unique_ids_key, employee_ids_to_keep)
  end

  def weird_user_prettyprinter(user_id)
    user = User.find(user_id)
    "I am #{user.name} number #{user_id}, of the tribe #{user.email}"
  end

  describe "#user_ids_to_remove" do
    def create_users_from_employee_ids(board, employee_ids)
      users = []
      employee_ids.each do |employee_id|
        users << FactoryBot.create(:user, employee_id: employee_id, demo: board)
      end
      users
    end

    before do
      @board = FactoryBot.create(:demo)
      @other_board = FactoryBot.create(:demo)

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
        rig_user_ids_for_bulk_removal(remover, arbitrary_ids)

        expect_user_ids_in_queue_and_object(remover, arbitrary_ids)
      end
    end
  end

  it "should exclude site admins" do
    board = FactoryBot.create(:demo)
    user = FactoryBot.create(:user, demo: board)
    user.is_site_admin = true
    user.save!

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    expect_user_ids_in_queue_and_object(remover, [])
  end

  it "should exclude anyone with a \"usual suspects\" email domain" do
    board = FactoryBot.create(:demo)
    usual_suspect_emails = %w(jimmy@airbo.com jane.doe@towerswatson.com bob@air.bo frieda@hengage.com)
    usual_suspect_emails.each{|email| FactoryBot.create(:user, email: email, demo: board)}

    guys_to_delete = FactoryBot.create_list(:user, 2, demo: board)
    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    expect_user_ids_in_queue_and_object(remover, guys_to_delete.map(&:id))
  end

  it "should easily let you iterate over users by means of a block" do
    board = FactoryBot.create(:demo)
    users = FactoryBot.create_list(:user, 2, demo: board)

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    rig_user_ids_for_bulk_removal(remover, users.map(&:id))

    result = []
    remover.each_user_id do |user_id|
      result << weird_user_prettyprinter(user_id)
    end

    expected_result = users.map{|user| weird_user_prettyprinter(user.id)}.sort
    expect(result.sort).to eq(expected_result)
  end

  it "should delete users in just the one board" do
    board = FactoryBot.create(:demo)
    users = FactoryBot.create_list(:user, 2, demo: board)
    user_ids = users.map(&:id)

    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    rig_user_ids_for_bulk_removal(remover, user_ids)

    remover.remove!
    

    expect(User.where(id: user_ids)).to be_empty
  end

  it "should un-join users in multiple boards" do
    board = FactoryBot.create(:demo)
    users = FactoryBot.create_list(:user, 2)
    users.each {|user| user.add_board(board)}
    users.each do |user|
      expect(user.demo_ids.size).to eq(2)
      expect(user.demo_ids).to include(board.id)
    end

    user_ids = users.map(&:id)
    remover = BulkLoad::UserRemover.new(board.id, object_key, :employee_id)
    rig_user_ids_for_bulk_removal(remover, user_ids)

    remover.remove!
    

    expect(User.where(id: user_ids).size).to eq(2)
    users.each do |user|
      user.reload
      expect(user.demo_ids.size).to eq(1)
      expect(user.demo_ids).not_to include(board.id)
    end
  end
end
