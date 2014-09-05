require 'spec_helper'

describe GuestUser do
  let(:user) { FactoryGirl.create(:guest_user) }

  def convert
    user.convert_to_full_user!("Jimmy Smits", "jimmy@example.com", "weakpassword")    
  end

  describe '#convert_to_full_user!' do
    it "should transfer over all the tile completions and acts that belong to the guest" do
      3.times { FactoryGirl.create :tile_completion }
      3.times { FactoryGirl.create :act }

      2.times { FactoryGirl.create :tile_completion, user: user }
      2.times { FactoryGirl.create :act, user: user }

      tile_completion_ids = user.tile_completion_ids
      act_ids = user.act_ids

      converted_user = convert
     
      converted_user.should_not == user

      converted_user.tile_completion_ids.sort.should == tile_completion_ids.sort
      converted_user.act_ids.sort.should == act_ids.sort
    end

    it "copies over points and tickets" do
      user.update_attributes(points: 234, tickets: 456)
      converted_user = convert
      converted_user.points.should == 234
      converted_user.tickets.should == 456
    end

    it "copies user in raffle information" do
      raffle1 = FactoryGirl.create(:raffle)
      user_in_raffle_info1 = FactoryGirl.create(:user_in_raffle_info, user: user, raffle: raffle1)
      raffle2 = FactoryGirl.create(:raffle)
      user_in_raffle_info2 = FactoryGirl.create(:user_in_raffle_info, user: user, raffle: raffle2)
      
      user.user_in_raffle_infos.should == [user_in_raffle_info1, user_in_raffle_info2]
      converted_user = convert
      converted_user.user_in_raffle_infos.pluck(:id).should == [user_in_raffle_info1.id, user_in_raffle_info2.id]
    end

    it "sets the name appropriately" do
      convert.name.should == "Jimmy Smits"
    end

    it "sets the email appropriately" do
      convert.email.should == "jimmy@example.com"
    end

    it "sets the password appropriately" do
      converted_user = convert
      authenticated_user = User.authenticate 'jimmy@example.com', 'weakpassword'
      authenticated_user.should == converted_user
    end

    it "puts the user in the same board as the guest" do
      convert.demo_id.should == user.demo_id
    end

    it "remembers a connection between the converted user and the guest" do
      converted_user = convert
      converted_user.original_guest_user.should == user
      user.converted_user.should == converted_user
    end

    it "claims to converted user" do
      convert.should be_claimed
    end

    it "sets characteristics to an empty hash" do
      convert.characteristics.should == {}
    end

    it "sets last_acted_at" do
      baseline = Time.now
      user.update_attributes(last_acted_at: baseline)
      convert.last_acted_at.to_i.should == baseline.to_i
    end

    it "copies the voteup-intro-seen flag" do
      user.voteup_intro_seen = true
      user.save!
      convert.voteup_intro_seen.should be_true
    end
  end

  describe "the unhappy path" do
    def unhappy_convert
      user.convert_to_full_user!(nil, nil, nil)
    end

    it "makes errors in the underlying user available in the GuestUser's own errors" do
      unhappy_convert
      user.errors.should_not be_empty
    end

    it "should leave no half-baked Users around" do
      unhappy_convert
      User.all.should have(0).users
    end

    it "should return nil" do
      unhappy_convert.should be_nil
    end

    it "requires a name" do
      user.convert_to_full_user!("", "jimmy@example.com", "weakpassword")
      user.errors.keys.should include(:name)
    end

    it "requires an email address" do
      user.convert_to_full_user!("jimmy", "", "weakpassword")
      user.errors.keys.should include(:email)
    end

    it "requires the email be unique if the email belongs to a claimed user" do
      FactoryGirl.create(:user, :claimed, email: "jimmy@example.com")
      convert
      user.errors.keys.should include(:email)
    end

    it "requires a password" do
      user.convert_to_full_user!("jimmy", "jimmy@example.com", "")
      user.errors.keys.should include(:password)
      user.errors.keys.should_not include(:password_confirmation) # just shut up already
    end
  end

  describe "#accepted_invitation_at" do
    it "should return the creation timestamp" do
      user.accepted_invitation_at.should == user.created_at
    end
  end

  [:location, :date_of_birth].each do |nil_field|
    describe "##{nil_field.to_s}" do
      it "should return nil" do
        user.send(nil_field).should be_nil
      end
    end
  end

  describe "notification method" do
    it "should return \"n/a\"" do
      user.notification_method.should == "n/a"
    end
  end

  describe "slug" do
    it "should return \"guestuser\"" do
      user.slug.should == "guestuser"
    end
  end

  describe "#data_for_mixpanel" do
    it "should include the game name" do
      user.demo.should_not be_nil
      user.data_for_mixpanel[:game].should == user.demo.name
    end

    it "should always report false for is_test_user" do
      user.data_for_mixpanel[:is_test_user].should == false
    end
  end

  describe "#is_test_user?" do
    it "should be false always" do
      user.is_test_user?.should be_false
    end
  end

  it "is not a client admin" do
    user.is_client_admin.should be_false
  end
end
