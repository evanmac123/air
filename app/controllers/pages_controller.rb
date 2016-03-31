class PagesController < HighVoltage::PagesController
  skip_before_filter :authorize
  before_filter :allow_guest_user
  before_filter :force_html_format
  before_filter :signed_out_only_on_root
  # before_filter :set_login_url
  # before_filter :set_new_board_url
  before_filter :display_social_links_if_marketing_page
  before_filter :set_page_name
  before_filter :set_page_name_for_mixpanel
  before_filter :set_user_for_mixpanel
  before_filter :handle_disabled_pages

  after_filter :update_seeing_marketing_page_for_first_time

  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  before_filter :find_tiles, if: :new_home?
  before_filter :set_all_tiles_displayed, if: :new_home? 
  before_filter :limit_tiles_to_batch_size, if: :new_home?
  before_filter :find_liked_and_copied_tile_ids
  before_filter :prep_explore_content


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
    login_as_guest(Demo.new) unless current_user
    super
  end

  private
  def find_tile_tags
    params[:tile_tag]
  end

  def new_home?
    true
  end

  def find_liked_and_copied_tile_ids
    @liked_tile_ids = []
    @copied_tile_ids =[]
  end

  def prep_explore_content
    @topics = Topic.rearrange_by_other
    @path_for_more_tiles = explore_path
    @parent_boards = Demo.where(is_parent: true)

    render_partial_if_requested(tag_click_source: 'Explore Main Page - Clicked Tag On Tile', thumb_click_source: 'Explore Main Page - Tile Thumbnail Clicked')


   #if params[:return_to_explore_source]
     #ping_action_after_dash params[:return_to_explore_source], {}, current_user
   #end

   #email_clicked_ping(current_user)
   #explore_intro_ping @show_explore_intro, params
   #explore_content_link_ping

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
