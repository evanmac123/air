require 'spec_helper'

describe UserIntro do
  FEATURE_NAME = :first_tile_hint
  GROUP_NAME = :new_users
  context "activate_first_tile_hint" do
    before do
      $rollout.deactivate(FEATURE_NAME)
    end
    after do
      $rollout.deactivate(FEATURE_NAME)
    end
    it "should activate for existing users without tile completions" do
      user1 = FactoryGirl.create :user
      FactoryGirl.create :tile_completion, user: user1
      user2 = FactoryGirl.create :user
      FactoryGirl.create :tile_completion, user: user2
      user3 = FactoryGirl.create :user
      user4 = FactoryGirl.create :user

      activate_first_tile_hint
      # users with completions don't have feature
      expect( $rollout.active?(FEATURE_NAME, user1) ).to be_false
      expect( $rollout.active?(FEATURE_NAME, user2) ).to be_false


      expect( $rollout.active?(FEATURE_NAME, user3) ).to be_true
      expect( $rollout.active?(FEATURE_NAME, user4) ).to be_true
    end

    it "should activate for new users" do
      activate_first_tile_hint

      user3 = FactoryGirl.create :user
      user4 = FactoryGirl.create :user

      expect( $rollout.active?(FEATURE_NAME, user3) ).to be_true
      expect( $rollout.active?(FEATURE_NAME, user4) ).to be_true
    end
  end

  def activate_first_tile_hint
    $rollout.define_group(GROUP_NAME) do |user|
      user.tile_completions.count == 0
    end

    $rollout.activate_group(FEATURE_NAME, GROUP_NAME)
  end
end
