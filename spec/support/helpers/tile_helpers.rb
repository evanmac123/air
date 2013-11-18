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

  # This guy returns an HTML table as an array of arrays where each internal array corresponds
  # to a row and the content of that array is the text in each of the columns.
  #
  # For example, the Tiles > Reports would look something like this:
  # [ [Tile 1, Headline 1, 333 users, 33%, ...],
  #   [Tile 2, Headline 2, 666 users, 66%, ...],
  #   [Tile 3, Headline 3, 999 users, 99%, ...],
  #   ...
  # ]
  #
  # While the Tiles > Manager would look like this:
  # [ ["Tile 9 Archive Edit Preview", "Tile 7 Archive Edit Preview", "Tile 5 Archive Edit Preview"],
  #   ["Tile 3 Archive Edit Preview", "Tile 1 Archive Edit Preview", "Tile 8 Archive Edit Preview"],
  #   ["Tile 6 Archive Edit Preview", "Tile 4 Archive Edit Preview", "Tile 2 Archive Edit Preview"],
  #   ["Tile 0 Archive Edit Preview"]
  # ]

  def table_content(table_selector)
    find(table_selector).all('tr').collect { |row| row.all('th, td').collect { |cell| cell.text } }
  end

  def table_content_without_activation_dates(table_selector)
    table_content(table_selector).map{|row_content| row_content.map {|cell_content| cell_content.gsub(/ (Activate|Deactivate|Active|Edit)(.*)?$/, '')}}
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
  DAY_TO_TIMES = { on_day:       :created_at,
                   activated_on: :activated_at,
                   archived_on:  :archived_at,
                   start_day:    :start_time,
                   end_day:      :end_time }
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
    find("section#active_tiles")
  end

  def archive_tab
    find("section#archived_tiles")
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
    have_selector 'td a img', count: num
  end
 
  def answer_field_selector
    "input[name='tile_builder_form[answers][]']"  
  end

  def fill_in_answer_field(index, text)
    fields = page.all(answer_field_selector)
    fields[index].set(text)
  end

  def fill_in_external_link_field(text)
    page.find("#tile_builder_form_link_address").set(text)
  end

  def select_correct_answer(index)
    page.find(".correct-answer-button[value=\"#{index}\"]").click
  end

  def after_tile_save_message(options={})
    "Tile created! We're resizing the graphics, which usually takes less than a minute. You can edit this tile, see this tile in the archive, or create a new tile"
  end

  def click_edit_link
    click_here_link[1].click
  end

  def create_existing_tiles(demo, status, num)
    FactoryGirl.create_list :tile, num, demo: demo, status: status
  end

  def have_first_tile(tile, status)
    have_selector "table tbody tr td[class='#{status}'][data-tile_id='#{tile.id}']"
  end

  def expect_current_tile_id(tile)
     page.find('.tile_holder')["data-current-tile-id"].should == tile.id.to_s
  end
end
