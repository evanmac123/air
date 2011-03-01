class Admin::BadMessagesController < ApplicationController
  def index
    @messages = BadMessage.most_recent_first
  end
end
