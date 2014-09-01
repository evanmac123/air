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
    table_content(table_selector).map{|row_content| row_content.select(&:present?).map {|cell_content| cell_content.gsub(/ (Post|Post again|Archive|Active|Edit)(.*)?$/, '')}}
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

  def draft_tab
    find("section#draft_tiles")
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

  def have_num_tile_links(num)
    have_selector ".tile_link", count: num
  end
 
  def answer_field_selector
    "input[name='tile_builder_form[answers][]']"  
  end

  def answer_link_selector
    ".tile_multiple_choice_answer a"
  end

  def fill_in_answer_field(index, text)
    page.find(".tile_question").click #just to close possible edit answer
    page.all(answer_link_selector)[index].click
    page.all(answer_field_selector)[index].set(text)
  end

  def fill_in_external_link_field(text)
    page.find("#tile_builder_form_link_address").set(text)
  end

  def fill_in_question text
    page.find(".tile_question").click if page.all(".tile_question").count > 0
    page.find("#tile_builder_form_question").set(text)
  end

  def click_make_copyable
    choose('allow_copying_on')
  end

  def click_make_nonpublic
    choose("share_off")
  end

  def click_make_noncopyable
    choose('allow_copying_off')
  end

  def select_correct_answer(index)
    page.find(".tile_question").click #just to close possible edit answer
    page.all(".tile_multiple_choice_answer a")[index].click
    page.find(".correct-answer-button[value=\"#{index}\"]").click
  end

  def add_tile_tag(tag)
    field = 'add-tag'
    fill_in field, with: tag    
    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    
    normalized_tag = tag.strip.capitalize.gsub(/\s+/, ' ')
    
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{normalized_tag}")}
    page.should have_selector("ul.ui-autocomplete li.ui-menu-item a:contains('#{normalized_tag}')")
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
    page.find('.tile_tags>li', text: tag).should have_content(normalized_tag(tag))
  end

  def after_tile_save_message(options={})
    "Tile #{options[:action] || 'create'}d! We're resizing the graphics, which usually takes less than a minute."
  end

  def click_edit_link
    click_here_link[1].click
  end

  def click_add_answer
    page.find(".add_answer").click
  end

  def fill_in_image_credit text
    #it's not easy to write in div though capybara
    #in few words about events: keydown deletes placeholder, 
    #html input text, keyup copy text to real textarea
    page.execute_script( "$('.image_credit_view').keydown().html('#{text}').keyup()" )
  end
  
  def normalized_tag(tag)
    tag.strip.gsub(/\s+/, ' ')
  end

  def add_new_tile_tag(tag)
    write_new_tile_tag tag
    
    a_text = "Click to add."
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{a_text}")}
    
    page.should have_selector("ul.ui-autocomplete li.ui-menu-item a:contains('#{a_text}')")
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
    page.find('.tile_tags>li', text: normalized_tag(tag)).should have_content(normalized_tag(tag))
  end

  def write_new_tile_tag tag
    field = 'add-tag'
    fill_in field, with: tag

    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
  end  
  
  def click_make_public
    find('#share_on').click    
  end
  def click_make_nonpublic
    find('#share_off').click    
  end
  
  def click_make_noncopyable
    find('#allow_copying_off').click
  end
  def click_make_copyable
    find('#allow_copying_on').click
  end
    
  def click_create_tile_button
    click_button "Save tile"
  end

  def after_tile_save_message(options={})
    "Tile #{options[:action] || 'create'}d! We're resizing the graphics, which usually takes less than a minute."
  end

  def click_edit_link
    click_here_link[1].click
  end

  def click_add_answer
    page.find(".add_answer").click
  end

  def fill_in_image_credit text
    #it's not easy to write in div though capybara
    #in few words about events: keydown deletes placeholder, 
    #html inputs text, keyup copies text to real textarea
    page.execute_script( "$('.image_credit_view').keydown().html('#{text}').keyup()" )
  end

  def fill_in_points points
    script = '$("#points_slider").slider("value", ' + (points.to_i * 10).to_s + ")"
    page.evaluate_script(script)
  end

  def fill_in_valid_form_entries(options = {}, with_public_and_copyable = false)
    click_answer = options[:click_answer] || 1
    question_type = options[:question_type] || Tile::QUIZ
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE

    choose_question_type_and_subtype question_type, question_subtype

    attach_tile "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    fill_in_image_credit "by Society"
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in_question "Who rules?"

    2.times { click_add_answer }

    fill_in_answer_field 0, "Me"
    fill_in_answer_field 1, "You"
    fill_in_answer_field 2, "He"

    click_answer.times { select_correct_answer 2 } if question_type == Tile::QUIZ

    fill_in_points "18"

    fill_in_external_link_field  "http://www.google.com/foobar"

    if with_public_and_copyable
      click_make_public
      tile_tag_title = options[:tile_tag_title] || 'Start tag'
      add_new_tile_tag(tile_tag_title)
    end
  end
  
  def click_edit_link
    click_here_link[1].click
  end

  def click_create_button
    click_button "Save tile"
  end

  def choose_question_type_and_subtype question_type, question_subtype
    page.find("##{question_type}").click()
    page.find("##{question_type}-#{question_subtype}").click()
  end


  def create_good_tile(with_public_and_copyable = false)
    fill_in_valid_form_entries({}, with_public_and_copyable)
    click_create_button
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

  def new_tile_placeholder_text
    "Add New Tile"
  end

  def click_new_tile_placeholder
    page.find('.creation-placeholder a', text: new_tile_placeholder_text).click
  end

  def expect_supporting_content(expected_content)
    expect_content expected_content
  end

  def expect_question(question)
    expect_content question
  end

  def expect_image_credit image_credit
    expect_content image_credit
  end

  def expect_points(points)
    expect_content "#{points} Points"
  end

  def answer(index)
    page.all('.tile_multiple_choice_answer')[index]  
  end

  def expect_answer(index, text)
    within answer(index) do
      expect_content text
    end
  end

  def click_answer(index)
    within answer(index) do
      page.find('a').click
    end
  end

  def expect_wrong_answer_reaction(index)
    within answer(index) do
      expect_content "Sorry, that's not it. Try again!"
    end
  end

  def expect_no_wrong_answer_reaction(index)
    expect_no_content "Sorry, that's not it. Try again!"
  end

  def expect_right_answer_reaction
    expect_content "Points 10/20, Tix 1"
  end

  def show_more_tiles_link
    page.find('a.show_more_tiles')
  end

  def expect_show_more_tiles_link_disabled?(disabled)
    if disabled
      page.should have_css("a.show_more_tiles[disabled]")
    else
      page.should_not have_css("a.show_more_tiles[disabled]")
    end
  end

  def expect_thumbnail_count(expected_count, tile_wrapper='.tile-wrapper')
    page.all(tile_wrapper).should have(expected_count).thumbnails
  end
  
  def expect_placeholder_count(expected_count)
    page.all('.placeholder_tile').should have(expected_count).placeholders
  end

  def attach_tile locator, path
    page.execute_script("$('#tile_builder_form_image').css('display','block')")
    attach_file locator, path
  end

  def show_tile_image
    page.should have_selector('img.tile_image', visible: true)
    page.should have_selector('.image_placeholder', visible: false)
  end

  def show_tile_image_placeholder
    page.should have_selector('img.tile_image', visible: false)
    page.should have_selector('.image_placeholder', visible: true)
  end

  # First "copy" in these next method name refers to the act of copying 
  # something.
  # Second "copy" means a piece of text.
  # If you have a problem with this, don't blame me, sue the President of 
  # English.
  
  def post_copy_copy
    "Success! Tile has been copied to your board's drafts section."
  end

  def completed_tiles_number
    page.find("#completed_tiles_num", :visible => false).text.to_i
  end

  def total_points
    page.find("#total_points").text.to_i
  end

  def close_voteup_intro
    click_link "Got it, thanks"
  end
end
