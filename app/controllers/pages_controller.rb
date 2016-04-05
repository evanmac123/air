class PagesController < HighVoltage::PagesController
  include TileBatchHelper

  skip_before_filter :authorize
  before_filter :allow_guest_user
  before_filter :force_html_format
  before_filter :signed_out_only_on_root
  before_filter :display_social_links_if_marketing_page
  before_filter :set_page_name
  before_filter :set_page_name_for_mixpanel
  before_filter :set_user_for_mixpanel
  before_filter :handle_disabled_pages
  before_filter :set_homepage_boards
  after_filter :update_seeing_marketing_page_for_first_time

  layout :layout_for_page

  DISABLED_PAGES = ["customer_tiles"]

  PAGE_NAMES_FOR_MIXPANEL = {
    'welcome'        => "Marketing Page",
    'home'           => "Landing Page V. 3/17/16",
    'customer_tiles' => 'customer tiles', # FIXME dead url?
    'more_info'      => 'More Info, marketing', # FIXME dead url?
    'privacy'        => 'privacy policy',
    'terms'          => 'terms and conditions'
  }


  def show
    @demos = Demo.where(public_slug: @homepage_boards.keys)
    prep_boards
    @demo = @sorted_demos.first
    
    login_as_guest(@demo) unless current_user
    super
  end

  private

  def set_homepage_boards

    @homepage_boards=  {
      "wellness-starter-kit" => "Wellness Starter Kit" , 
      "healthplanbasics" => "Health Plan Basics", 
      "internal-validation" =>"Internal Validation" 
    }
  end

  def sort_demos
    @sorted_demos = @homepage_boards.map do|slug, title|
      @demos.where(public_slug: slug).first
    end
  end

  def prep_boards
    @tile_set = []
    sort_demos
    @sorted_demos.each do |demo|
      current_user.demo = demo
      @tile_set << Tile.displayable_categorized_to_user(current_user, tile_batch_size)
    end
  end


  def layout_for_page
    case page_name
    when 'privacy', 'terms'
      'external'
    # when 'welcome', 'product', 'asha', 'company', 'home', 'fujifilm', 'case-studies', 'wellness'
      # 'standalone'
    when 'more_info',  # FIXME dead url?
      @body_id = "homepage"
      'external_marketing'
    when 'heineken', 'miltoncat', 'customer_tiles'
      'external_marketing'
    else
      'standalone'
    end
  end

  def signed_out_only_on_root
    return unless params[:id] == 'home'
    redirect_to home_path if signed_in?
  end


  def display_social_links_if_marketing_page
    display_social_links if %w(more_info asha miltoncat heineken fujifilm customer_tiles).include?(params[:id])
  end

  def page_name
    page_name = params[:id] || params[:action]
  end

  def set_page_name
    flash.now[:failure] ||= params[:flash][:failure] if params[:flash]
    @page_name = page_name
  end

  def set_page_name_for_mixpanel
    @page_name_for_mixpanel = page_name_for_mixpanel
  end

  def page_name_for_mixpanel
    if (name = PAGE_NAMES_FOR_MIXPANEL[page_name]).present?
      name
    else
      page_name
    end
  end

  def set_user_for_mixpanel
    @user_for_mixpanel ||= User.where(id: session[:user_id]).first
  end

  def update_seeing_marketing_page_for_first_time
    return unless current_user && current_user.respond_to?("seeing_marketing_page_for_first_time=")
    current_user.update_attributes(seeing_marketing_page_for_first_time: false)
  end

  def handle_disabled_pages
    raise ActionController::RoutingError.new("Page not Found") if DISABLED_PAGES.include?(params[:id])
  end
end
