require "spec_helper"

describe GridQuery::TileActions do
  let!(:demo) { FactoryBot.create :demo }
  let!(:other_demo) { FactoryBot.create :demo }
  let!(:tile) { FactoryBot.create :tile, demo: demo, multiple_choice_answers: ["Ham", "Eggs", "A V8 Buick"] }
  let!(:other_tile) { FactoryBot.create :tile, demo: demo, multiple_choice_answers: ["Good", "Bad", "Ugly"] }

  def user_actions user, tile, views = 1, interacted = false, answer_index = nil
    FactoryBot.create :tile_viewing, user: user, tile: tile, views: views
    if interacted
      FactoryBot.create :tile_completion, user: user, tile: tile, answer_index: answer_index
    end
  end

  def create_users num, demo, name
    (0..num).to_a.map do |i|
      FactoryBot.create :user, name: "#{name.humanize}#{i}", email: "#{name}#{i}@gmail.com", demo: demo
    end
  end

  def make_table query
    query.map(&:attributes).map do |row|
      row.delete("completion_date")
      row.delete("user_id")
      row.delete("id")
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
    # viewed only
    [3,4,5].each do |i|
      user_actions @users[i], tile, i
    end
    # didn't view
    # users 6 7 8
  end

  it "should return 'all'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, "all").query.order("users.id ASC"))

    expect(table.map(&:first)).to eq(["Good guy0", "Good guy1", "Good guy2", "Good guy3", "Good guy4", "Good guy5", "Good guy6", "Good guy7", "Good guy8"])
  end

  it "should return 'viewed only'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_answer_index
    table = make_table(GridQuery::TileActions.new(tile, "viewed_only").query.order("users.id ASC"))
    expect(table.map(&:first)).to eq(["Good guy3", "Good guy4", "Good guy5"])
  end

  it "should return 'not_viewed'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_an,nilswer_index
    table = make_table(GridQuery::TileActions.new(tile, "not_viewed").query.order("users.id ASC"))

    expect(table.map(&:first)).to eq(["Good guy6", "Good guy7", "Good guy8"])
  end

  it "should return 'interacted'" do
    # result is set of rows(arrays) with columns:
    # user_name | user_email | tile_views | tile_an,nilswer_index
    tile_actions = GridQuery::TileActions.new(tile, "interacted").query.order("users.id ASC")

    table = make_table(tile_actions)

    expect(table.map(&:first)).to eq(["Good guy0", "Good guy1", "Good guy2"])
  end
end
