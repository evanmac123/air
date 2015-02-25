require "spec_helper"

describe "shared/_desktop_board_switcher.html.erb" do
  it "does not show the board creation link if passed a non-site-admin user who's in a paid board" do
    user = FactoryGirl.build_stubbed(:user, name: "Rudolph")
    user.stubs(:not_in_any_paid_boards?).returns(false)
    user.stubs(:is_site_admin).returns(false)
    user.stubs(:has_boards_to_switch_to?).returns(false)
    user.stubs(:can_create_board?).returns(false)
    user.stubs(:is_site_admin).returns(false)

    render "shared/desktop_board_switcher.html.erb", user: user

    rendered.should_not have_link("Create new board")
  end
end
