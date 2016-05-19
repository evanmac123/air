class UserProgressPresenter
  include ActionView::Helpers::NumberHelper

  def initialize(user, raffle, browser)
    @user = user
    @raffle = raffle
    @browser = browser
  end

#  def cache_key
    #@cache_key ||= [
      #self.class.to_s, 
      #'v1.pwd'
    #].join('-')
  #end

  def available_tile_count
    @available_tile_count ||= @user.available_tiles_on_current_demo.count
  end

  def completed_tile_count
    @completed_tile_count ||= @user.completed_tiles_on_current_demo.count
  end

  def some_tiles_undone?
    available_tile_count != completed_tile_count  
  end

  def points
    @points ||= number_with_delimiter(@user.points)
  end

  def old_browser?
    @browser.ie6? || @browser.ie7? || @browser.ie8?  
  end

  def persist_locally?
    false
  end

  def config
    {user: @user.id, 
     demo: @user.demo.id, 
     available: available_tile_count, 
     completed: completed_tile_count, 
     points: points, 
     legacyBrowser: old_browser?
    }
  end
end
