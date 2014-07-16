require "spec_helper"

describe "shared/_board_settings_single_board.html.erb" do
  def expect_no_delete_link
    rendered.should_not have_link("X", href: "#")
  end

  it "should not display delete links for paid boards" do
    render "shared/board_settings_single_board", 
            as_admin: false,
            board:    FactoryGirl.build_stubbed(:demo, :paid)

    expect_no_delete_link
  end

  it "should not display delete links for boards you're in as a client admin" do
    render "shared/board_settings_single_board", 
            as_admin: true,
            board:    FactoryGirl.build_stubbed(:demo)

    expect_no_delete_link
  end
end
