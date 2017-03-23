class OnboardingSubnavPresenter
  include Rails.application.routes.url_helpers

  attr_reader :user_onboarding

  def initialize(user_onboarding)
    @user_onboarding = user_onboarding
  end

  def items_with_corrected_params
    elements = set_subnav_elements
    elements.each do |item_params|
      yield correct_params(item_params)
    end
  end

  private

  def set_subnav_elements
    subnav_elements
  end

  def correct_params(params={})
    params[:icon] ||= nil
    params[:image] ||= nil
    params[:blocked] ||= nil
    params[:link_options] ||= {}
    params
  end

  def subnav_elements
    [{
      item_id: "my_airbo_nav",
      link: user_onboarding.id ? myairbo_path(user_onboarding) : "#",
      image: "airbo_logo_lightblue_square.png",
      text: "My Airbo"
    },
    {
      item_id: "board_activity",
      link: user_onboarding.id ? onboarding_activity_path(user_onboarding) : "#",
      icon: "line-chart",
      text: "Reporting"
    },
    {
      item_id: "share_airbo",
      link: "",
      icon: "share-alt",
      text: "Share"
    },
    {
      item_id: "contact_us",
      link: "",
      icon: "info",
      text: "Help"
    },]
  end
end
