require "spec_helper"

describe GridQuery::TileActions do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:other_demo) { FactoryGirl.create :demo }
  let!(:tile) { FactoryGirl.create :tile, demo: demo, multiple_choice_answers: ["Ham", "Eggs", "A V8 Buick"] }
  let!(:other_tile) { FactoryGirl.create :tile, demo: demo, multiple_choice_answers: ["Good", "Bad", "Ugly"] }

  def user_actions user, tile, views = 1, interacted = false, answer_index = nil
    FactoryGirl.create :tile_viewing, user: user, tile: tile, views: views
    if interacted
      FactoryGirl.create :tile_completion, user: user, tile: tile, answer_index: answer_index
    end
  end

  def create_users num, demo, name
    (0..num).to_a.map do |i|
      FactoryGirl.create :user, name: "#{name.humanize}#{i}", email: "#{name}#{i}@gmail.com", demo: demo
    end
  end

  # def make_table query
  #   query.map do |user|
  #     [
  #       user.name,
  #       user.email,
  #       user.tile_viewings.where(tile: tile).first.try(:views) || "-",
  #       if user.tile_completions.where(tile: tile).first
  #         tile.multiple_choice_answers[user.tile_completions.where(tile: tile).first.answer_index][0...15]
  #       else
  #         "-"
  #       end,
  #       if user.tile_completions.where(tile: tile).present?
  #         user.tile_completions.where(tile: tile).first.created_at.strftime('%-m/%-d/%Y')
  #       else
  #         "-"
  #       end
  #     ]
  #   end
  # end

  def make_table query
    query.map(&:attributes).map do |row|
      # row["completion_date"] = Time.parse(row["completion_date"] + " UTC") if row["completion_date"]
      row.delete("completion_date")
      row
    end.map(&:values)
  end

  before do
    @users = create_users 8, demo, "good_guy"
    @other_users = create_users 2, other_demo, "other_guy"
    # viewed and interacted
    [0,1,2].each do |i|
      user_actions @users[i], tile, i+1, true, i
    end
    user_actions @other_users[0], other_tile, 2, true, 0
    # viewed and didn't interact
    [3,4,5].each do |i|
      user_actions @users[i], tile, i
    end
    # didn't view
    # users 6 7 8
  end

  it "should return 'all'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile).query.order("users.id ASC"))
    table.should == [
      ["Good guy0", "good_guy0@gmail.com", "1", "0"],
      ["Good guy1", "good_guy1@gmail.com", "2", "1"],
      ["Good guy2", "good_guy2@gmail.com", "3", "2"],
      ["Good guy3", "good_guy3@gmail.com", "3", nil],
      ["Good guy4", "good_guy4@gmail.com", "4", nil],
      ["Good guy5", "good_guy5@gmail.com", "5", nil],
      ["Good guy6", "good_guy6@gmail.com", nil, nil],
      ["Good guy7", "good_guy7@gmail.com", nil, nil],
      ["Good guy8", "good_guy8@gmail.com", nil, nil]
    ]
  end

  it "should return 'viewed'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, :viewed).query.order("users.id ASC"))
    table.should == [
      ["Good guy0", "good_guy0@gmail.com", "1", "0"],
      ["Good guy1", "good_guy1@gmail.com", "2", "1"],
      ["Good guy2", "good_guy2@gmail.com", "3", "2"],
      ["Good guy3", "good_guy3@gmail.com", "3", nil],
      ["Good guy4", "good_guy4@gmail.com", "4", nil],
      ["Good guy5", "good_guy5@gmail.com", "5", nil]
    ]
  end

  it "should return 'not_viewed'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, :not_viewed).query.order("users.id ASC"))
    table.should == [
      ["Good guy6", "good_guy6@gmail.com", nil, nil],
      ["Good guy7", "good_guy7@gmail.com", nil, nil],
      ["Good guy8", "good_guy8@gmail.com", nil, nil]
    ]
  end

  it "should return 'viewed_and_interacted'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, :viewed_and_interacted).query.order("users.id ASC"))
    table.should == [
      ["Good guy0", "good_guy0@gmail.com", "1", "0"],
      ["Good guy1", "good_guy1@gmail.com", "2", "1"],
      ["Good guy2", "good_guy2@gmail.com", "3", "2"]
    ]
  end

  it "should return 'viewed_and_not_interacted'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, :viewed_and_not_interacted).query.order("users.id ASC"))
    table.should == [
      ["Good guy3", "good_guy3@gmail.com", "3", nil],
      ["Good guy4", "good_guy4@gmail.com", "4", nil],
      ["Good guy5", "good_guy5@gmail.com", "5", nil]
    ]
  end
end
