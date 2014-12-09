require 'acceptance/acceptance_helper'

feature 'Sends explore digest' do
  before do
    @tiles = FactoryGirl.create_list(:multiple_choice_tile, 5, :public)
    @admin = an_admin

    crank_dj_clear
    ActionMailer::Base.deliveries.clear

    visit new_admin_explore_digest_path(as: @admin)
  end

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

  def fill_in_valid_tile_fields
    4.times do |n|
      page.all('#explore_digest_form_tile_ids_')[n].set(@tiles[n].id)
    end
  end

  def click_test_button
    click_button "Send test digest to self"
  end

  def click_send_button
    click_button "Send real digest"
  end

  def expect_correct_digest(email)
    open_email email

    current_email.subject.should == valid_subject
    current_email.to_s.should =~ /#{valid_headline}.*#{valid_custom_message}/m

    tile_headlines = @tiles[0,4].map(&:headline)
    current_email.to_s.should =~ /#{tile_headlines[0]}.*#{tile_headlines[1]}.*#{tile_headlines[2]}.*#{tile_headlines[3]}/m
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

    it "changes the order of the tiles on the explore page itself"
  end
end
