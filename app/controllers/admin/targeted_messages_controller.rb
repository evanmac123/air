class Admin::TargetedMessagesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics(@demo)
  end
end
