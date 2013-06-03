module TileHelpers

  # Allows you to use Timecop with normal string dates instead of Ruby's convoluted Time class
  #
  # Sample usage:
  #
  # on_day '7/4/2013' do
  #   visit manage_tiles_page
  #   select_tab 'Digest'
  #    :   :   :   :   :
  # end

  DATE_REG_EXPR = /(\d{1,2})\/(\d{1,2})\/(\d{4})/  # e.g. 7/4/2013 -or- 07/04/2013

  def on_day(day)
    travel_to_day day
    yield
  ensure
    Timecop.return
  end

  def travel_to_day(day)
    day.match DATE_REG_EXPR
    time = Time.new $3, $1, $2
    Timecop.travel(time)
  end

  # -------------------------------------------------

  DAY_TO_TIMES = { on_day:    :created_at,
                   start_day: :start_time,
                   end_day:   :end_time }

  # Allows you to create tiles with normal string dates instead of Ruby's convoluted Time class
  # Hash Key: What you use in your code ; Hash Value: Actual Tile attribute
  #
  # Sample usage:
  #
  # create_tile on_day: '7/5/2013', headline: "My Tile Headline", start_day: '7/4/2013', end_day: '7/6/2013'

  def create_tile(options = {})
    DAY_TO_TIMES.each_pair do |day, time|
      day = options.delete day
      if day
        day.match DATE_REG_EXPR
        options[time] = Time.new $3, $1, $2
      end
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
end