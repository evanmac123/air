require 'spec_helper'

describe GuestUser do
  it { is_expected.to have_many(:tile_viewings) }
  it { is_expected.to have_many(:viewed_tiles) }

  let(:user) { FactoryGirl.create(:guest_user) }

  def convert
    user.convert_to_full_user!("Jimmy Smits", "jimmy@example.com", "weakpassword")
  end

  describe '#convert_to_full_user!' do
    it "should transfer over all the tile viewings, tile completions and acts that belong to the guest" do
      3.times { FactoryGirl.create :tile_viewing }
      3.times { FactoryGirl.create :tile_completion }
      3.times { FactoryGirl.create :act }

      2.times { FactoryGirl.create :tile_viewing, user: user }
      2.times { FactoryGirl.create :tile_completion, user: user }
      2.times { FactoryGirl.create :act, user: user }

      tile_viewing_ids = user.tile_viewing_ids
      tile_completion_ids = user.tile_completion_ids
      act_ids = user.act_ids

      converted_user = convert

      expect(converted_user).not_to eq(user)

      expect(converted_user.tile_viewing_ids.sort).to eq(tile_viewing_ids.sort)
      expect(converted_user.tile_completion_ids.sort).to eq(tile_completion_ids.sort)
      expect(converted_user.act_ids.sort).to eq(act_ids.sort)
    end

    it "copies over points and tickets" do
      user.update_attributes(points: 234, tickets: 456)
      converted_user = convert
      expect(converted_user.points).to eq(234)
      expect(converted_user.tickets).to eq(456)
    end

    it "copies user in raffle information" do
      raffle1 = FactoryGirl.create(:raffle)
      user_in_raffle_info1 = FactoryGirl.create(:user_in_raffle_info, user: user, raffle: raffle1)
      raffle2 = FactoryGirl.create(:raffle)
      user_in_raffle_info2 = FactoryGirl.create(:user_in_raffle_info, user: user, raffle: raffle2)

      expect(user.user_in_raffle_infos).to eq([user_in_raffle_info1, user_in_raffle_info2])
      converted_user = convert
      expect(converted_user.user_in_raffle_infos.pluck(:id)).to eq([user_in_raffle_info1.id, user_in_raffle_info2.id])
    end

    it "sets the name appropriately" do
      expect(convert.name).to eq("Jimmy Smits")
    end

    it "sets the email appropriately" do
      expect(convert.email).to eq("jimmy@example.com")
    end

    it "sets the password appropriately" do
      converted_user = convert
      authenticated_user = User.authenticate 'jimmy@example.com', 'weakpassword'
      expect(authenticated_user).to eq(converted_user)
    end

    it "puts the user in the same board as the guest" do
      expect(convert.demo_id).to eq(user.demo_id)
    end

    it "remembers a connection between the converted user and the guest" do
      converted_user = convert
      expect(converted_user.original_guest_user).to eq(user)
      expect(user.converted_user).to eq(converted_user)
    end

    it "claims to converted user" do
      expect(convert).to be_claimed
    end

    it "sets characteristics to an empty hash" do
      expect(convert.characteristics).to eq({})
    end

    it "sets last_acted_at" do
      baseline = Time.now
      user.update_attributes(last_acted_at: baseline)
      expect(convert.last_acted_at.to_i).to eq(baseline.to_i)
    end
  end

  describe "the unhappy path" do
    def unhappy_convert
      user.convert_to_full_user!(nil, nil, nil)
    end

    it "makes errors in the underlying user available in the GuestUser's own errors" do
      unhappy_convert
      expect(user.errors).not_to be_empty
    end

    it "should leave no half-baked Users around" do
      unhappy_convert
      expect(User.all.size).to eq(0)
    end

    it "should return nil" do
      expect(unhappy_convert).to be_nil
    end

    it "requires a name" do
      user.convert_to_full_user!("", "jimmy@example.com", "weakpassword")
      expect(user.errors.keys).to include(:name)
    end

    it "requires an email address" do
      user.convert_to_full_user!("jimmy", "", "weakpassword")
      expect(user.errors.keys).to include(:email)
    end

    it "requires the email be unique if the email belongs to a claimed user" do
      FactoryGirl.create(:user, :claimed, email: "jimmy@example.com")
      convert
      expect(user.errors.keys).to include(:email)
    end

    it "requires a password" do
      user.convert_to_full_user!("jimmy", "jimmy@example.com", "")
      expect(user.errors.keys).to include(:password)
      expect(user.errors.keys).not_to include(:password_confirmation) # just shut up already
    end

    it "requires a valid location name if one is present" do
      bad_location_name = "Nowhere"
      user.convert_to_full_user!("jimmy", "jimmy@example.com", "foobar", bad_location_name)
      expect(user.errors.keys).to include(:location_id)
    end
  end

  describe "#accepted_invitation_at" do
    it "should return the creation timestamp" do
      expect(user.accepted_invitation_at).to eq(user.created_at)
    end
  end

  [:location, :date_of_birth].each do |nil_field|
    describe "##{nil_field.to_s}" do
      it "should return nil" do
        expect(user.send(nil_field)).to be_nil
      end
    end
  end

  describe "notification method" do
    it "should return \"n/a\"" do
      expect(user.notification_method).to eq("n/a")
    end
  end

  describe "slug" do
    it "should return \"guestuser\"" do
      expect(user.slug).to eq("guestuser")
    end
  end

  describe "#data_for_mixpanel" do
    it "should include the game ID" do
      expect(user.demo).not_to be_nil
      expect(user.data_for_mixpanel[:game]).to eq(user.demo.id)
    end
  end

  describe "#is_test_user?" do
    it "should be false always" do
      expect(user.is_test_user?).to be_falsey
    end
  end

  it "is not a client admin" do
    expect(user.is_client_admin).to be_falsey
  end
end
