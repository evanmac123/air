require 'acceptance/acceptance_helper'

feature 'Sends explore digest' do
  SEND_BUTTON_COPY = "Send real digest"
  TEST_BUTTON_COPY = "Send test digest to self"

  def valid_subject
    "I am thy Subjekt"
  end

  def valid_headline
    "Extra extra read all about it"
  end

  def valid_custom_message
    "Now is the time for all good men to come to."
  end

  def fill_in_valid_message_entries
    fill_in "explore_digest_form[subject]", with: valid_subject
    fill_in "explore_digest_form[headline]", with: valid_headline
    fill_in "explore_digest_form[custom_message]", with: valid_custom_message
  end

  def fill_in_valid_tile_fields(tile_ids = @tiles.map(&:id))
    4.times do |n|
      page.all('#explore_digest_form_tile_ids_')[n].set(tile_ids[n])
    end
  end

  def click_test_button
    click_button TEST_BUTTON_COPY
  end

  def click_send_button
    click_button SEND_BUTTON_COPY
  end

  def expect_correct_digest(email)
    open_email email

    current_email.subject.should == valid_subject
    current_email.to_s.should =~ /#{valid_headline}.*#{valid_custom_message}/m
    # actually it's 50, but it works with 47
    tile_headlines = @tiles[0,4].map{|t| t.headline.truncate(47) } 
    current_email.to_s.should =~ /#{tile_headlines[0]}.*#{tile_headlines[1]}.*#{tile_headlines[2]}.*#{tile_headlines[3]}/m
  end

  shared_examples_for 'reordering the tiles' do |button_label|
    it "changes the order of the tiles on the explore page itself" do
      fill_in_valid_message_entries

      indices = [2, 0, 3, 1]
      tile_ids = indices.map{|index| @tiles[index].id}
      fill_in_valid_tile_fields(tile_ids)
      click_button button_label

      visit explore_path
      page.body.should =~ /#{@tiles[2].headline}.*#{@tiles[0].headline}.*#{@tiles[3].headline}.*#{@tiles[1].headline}/m
    end
  end

  before do
    @tiles = FactoryGirl.create_list(:multiple_choice_tile, 5, :public)
    @admin = an_admin

    crank_dj_clear
    ActionMailer::Base.deliveries.clear

    visit new_admin_explore_digest_path(as: @admin)
  end

  context 'as a test' do
    it 'works' do
      fill_in_valid_message_entries
      fill_in_valid_tile_fields

      click_test_button

      crank_dj_clear

      ActionMailer::Base.deliveries.should have(1).email
      expect_correct_digest(@admin.email)
    end

    it_should_behave_like "reordering the tiles", TEST_BUTTON_COPY
  end

  context 'for real' do
    it 'works' do
      other_admins = FactoryGirl.create_list(:client_admin, 3)
      regular_user = FactoryGirl.create(:user)

      fill_in_valid_message_entries
      fill_in_valid_tile_fields

      click_send_button
      crank_dj_clear

      ActionMailer::Base.deliveries.should have(3).emails
      other_admins.each do |admin|
        expect_correct_digest(admin.email)
      end
    end

    it_should_behave_like "reordering the tiles", SEND_BUTTON_COPY
  end
end
