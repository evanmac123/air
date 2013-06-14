module TileHelpers

  # Custom selectors

  # This selector is for tiles contained in a table in the tile manager
  #
  # Usage: find(:tile, tile)
  #
  Capybara.add_selector(:tile) do
    xpath { |tile| ".//td[@data-tile_id='#{tile.id}']" }
  end

  # -------------------------------------------------

  DATE_REG_EXPR = /(\d{1,2})\/(\d{1,2})\/(\d{4})/  # e.g. 7/4/2013 -or- 07/04/2013

  def day_to_time(day)
    day.match DATE_REG_EXPR
    Time.new $3, $1, $2
  end

  # Allows you to use Timecop with normal string dates instead of Ruby's convoluted Time class
  #
  # Usage:
  #
  # on_day '7/4/2013' do
  #   visit manage_tiles_page
  #   select_tab 'Digest'
  #    :   :   :   :   :
  # end
  #
  def on_day(day)
    travel_to_day day
    yield
  ensure
    Timecop.return
  end

  def travel_to_day(day)
    Timecop.travel(day_to_time(day))
  end

  # -------------------------------------------------

  # Allows you to create tiles with normal string dates instead of Ruby's convoluted Time class

  # Key: What you use in your code ; Value: Actual Tile attribute
  DAY_TO_TIMES = { on_day:    :created_at,
                   start_day: :start_time,
                   end_day:   :end_time }
  # Usage:
  #
  # create_tile on_day: '7/5/2013', headline: "My Tile Headline", start_day: '7/4/2013', end_day: '7/6/2013'
  #
  # Note that 'demo' must be defined in a 'let(:demo) {~~~~}' statement in the specs that call this.
  # (Don't know if that's a stupid requirement or not, but since all tiles require a 'demo', this just makes it easier.I think.)
  #
  def create_tile(options = {})
    DAY_TO_TIMES.each_pair do |day, time|
      day = options.delete day
      options[time] = day_to_time(day) if day
    end

    FactoryGirl.create :tile, options.merge(demo: demo)
  end

  # -------------------------------------------------

  def tab(label)
    find("#tile-manager-tabs ##{label.downcase}")
  end

  def active_tab
    tab('Active')
  end

  def digest_tab
    tab('Digest')
  end

  def archive_tab
    tab('Archive')
  end

  def select_tab(tab)
    click_link tab
  end

  # -------------------------------------------------

  def tile_manager_page
    client_admin_tiles_path
  end

  def refresh_tile_manager_page
    visit tile_manager_page
  end

  # -------------------------------------------------

  def contain(text)
    have_text text
  end

  def have_tile_image(options)
    have_selector '.tile_thumbnail img', options
  end

  def have_num_tiles(number, options = {})
    have_tile_image options.merge(count: number)
  end

  # -------------------------------------------------

  def have_tiles_digest_body_text
    have_body_text 'Check out your'
    have_body_text acts_url(protocol: email_link_protocol, host: email_link_host)
    have_body_text 'new tiles'

    have_body_text 'Interact, earn points, and see how your colleagues are doing!'
    have_body_text 'View your tiles'
  end

  def have_company_logo_image_link
    have_selector "a[id $= _logo][target = _blank] img[src ^= http]"
  end

  def have_view_your_tiles_link
    have_link "View your tiles", href: acts_url(protocol: email_link_protocol, host: email_link_host)
  end

  def have_num_tile_image_links(num)
    have_selector "div.image a[href='#{acts_url(protocol: email_link_protocol, host: email_link_host)}'] img", count: num
  end
end