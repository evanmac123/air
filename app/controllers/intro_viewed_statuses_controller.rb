class IntroViewedStatusesController < ApplicationController
  skip_before_filter :authorize
  before_filter :authorize_by_explore_token

  before_filter :allow_guest_user
  before_filter :authorize_as_guest

  def update
    # I am sure that soon we'll put in some kind of dispatch hash, and
    # eventually a service, as we add more flags and more logic--but for now,
    # let's just:
   
    if params[:share_link_intro_seen] == 'true'
      current_user.share_link_intro_seen = true
      current_user.save!
    end

    # Since after all, there can be too much of a good thing.

    render nothing: true
  end

  protected

  def find_current_board
    current_user.demo
  end
end
