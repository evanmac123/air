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

  # This guy returns an HTML table as an array of arrays of cell text where each
  # array represents a row and the content of that array represents the columns.
  #
  # Note: For tiles there are only 3 elements per row, but the "..." in each "row" => the more general case
  #
  # e.g. [ [Tile 1, Tile 2, Tile 3, ...], [Tile 4, Tile 5, Tile 6, ...], [Tile 7, Tile 8, Tile 9, ...], ... ]
  #
  def table_content(table_selector)
    find(table_selector).all('tr').collect { |row| row.all('th, td').collect { |cell| cell.text } }
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
  # (Don't know if that's a stupid requirement or not, but since all tiles require a 'demo', this just makes it easier. I think.)
  #
  # Yeah, it came back to bite me. So that's why I only merge it if it isn't supplied in the 'options' hash
  #
  def create_tile(options = {})
    DAY_TO_TIMES.each_pair do |day, time|
      day = options.delete day
      options[time] = day_to_time(day) if day
    end

    options.merge!(demo: demo) unless options.has_key?(:demo)

    FactoryGirl.create :tile, options
  end

  # -------------------------------------------------

  def tab(label)
    find("#tile-manager-tabs, #tile-reports-tabs").find("##{label.downcase}")
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

  def have_num_tile_image_links(num)
    have_selector 'div.image a img', count: num
  end
  
  def fill_in_answer_field(index, text)
    fields = page.all("input[name='tile_builder_form[answers][]']")
    fields[index].set(text)
  end

  def fill_in_external_link_field(text)
    page.find("#tile_builder_form_link_address").set(text)
  end

  def after_tile_save_message(options={})
    if options[:hide_activate_link]
      "This is your finished tile. Click here to edit it."
    else
      "This is your finished tile. Click here to activate it and make it available to employees (otherwise it'll stay in the archive). Click here to edit it."
    end
  end

  def click_here_link
    page.all("a", text: 'Click here')
  end

  def click_activate_link
    click_here_link[0].click
  end

  def click_edit_link
    click_here_link[1].click
  end
end
