require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself", js:true do
  let! (:client_admin) { FactoryBot.create(:client_admin) }

  before :each do
    client_admin.demo.update_attributes(public_slug: 'heyfriend')
    tile = FactoryBot.create :tile, demo: client_admin.demo
    user = FactoryBot.create :user, demo: client_admin.demo
    FactoryBot.create(:tile_completion, tile: tile, user: user)
  end

  # not sure if it even helps
  # these tests just fail to often an leave records in test db.
  after :each do
    Tile.delete_all
    Demo.delete_all
    User.delete_all
  end

  def click_on_link
    page.find('.switch').click
  end

  def click_off_link
    page.find('.switch').click
  end

  def share_url_regex(slug)
    expected_path = public_board_path(public_slug: slug)
    %r"http://(127.0.0.1:\d+|www.example.com)#{expected_path}"
  end

  def expect_displayed_share_url(slug)
    expect(page.body).to match(share_url_regex(slug))
  end

  def expect_on_engaged
    expect(page).to have_css(".public.engaged")
    expect(page).to have_css(".private.disengaged")
  end

  def expect_off_engaged
    expect(page).to have_css(".private.engaged")
  end

  def public_board_section
    ".js-share-board-link-component"
  end

  context "when the board is public" do
    before :each do
      visit client_admin_share_path(as: client_admin)
      find('.js-share-board-link-component-tab').click
    end

    it "should tell the user the board's not private" do
      expect_on_engaged
    end

    it "should allow the client admin to set it private", js: true do
      expect_on_engaged
      click_off_link
      expect_off_engaged
    end

    it "should show the public slug regardless" do
      expect_displayed_share_url('heyfriend')
    end

    it "should display tooltip on mouseover question mark icon", js: true do
      within public_board_section do
        page.find('.fa-question-circle').hover
      end
      expect(page).to have_content "In a public board, anyone can participate using the Board Link. In a private board, only users you specifically add can participate, and the Board Link isn't active."
    end
  end

  context "when the board is already private" do
    before do
      client_admin.demo.update_attributes(is_public: false)
      visit client_admin_share_path(as: client_admin)
      find('.js-share-board-link-component-tab').click
    end

    it "should show the URL" do
      expect_displayed_share_url('heyfriend')
    end

    it "should look switched on" do
      expect_off_engaged
    end

    it "should allow the client admin to switch it off", js: true do
      click_off_link
      expect_on_engaged
    end
  end
end
