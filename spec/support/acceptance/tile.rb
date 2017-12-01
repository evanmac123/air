module TileHelpers

  # Custom selectors

  # This selector is for tiles contained in a table in the tile manager
  #
  # Usage: find(:tile_image, tile_image)

  Capybara.add_selector(:tile_image) do
    xpath { |tile_image| ".//div[@data-tile-image-id='#{tile_image.id}']" }
  end

  def tile_image_selector
    ".tile_image_block:not(.new_image)"
  end

  def tile_image_block ti
    page.find(:tile_image, ti)
  end

  def section_tile_headlines(selector)
    find(selector).all('.tile_container:not(.placeholder_container)').collect { |tile| tile.find(".headline .text").text }
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
    "textarea[name='tile[answers][]']"
  end

  def answer_link_selector
    ".js-answer-btn"
  end

  def fill_in_answer_field(index, text)
    page.all(answer_link_selector)[index].click
    page.find(answer_field_selector, visible: true).set(text)
    page.find("#quiz-answer").click
  end

  def fill_in_external_link_field(text)
    page.find("#tile_link_address").set(text)
  end

  def fill_in_question text
    page.find("#tile_question").set(text)
  end

  def select_correct_answer(index)
    page.find("input[type='radio'][value='#{index}'].correct-answer-button" ).click
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
    # it's not easy to write in div with capybara
    # few words about events: keydown deletes placeholder,
    # html inputs text, keyup copies text to real textarea
    page.execute_script( "$('.image_credit_view').keydown().html('#{text}').keyup()" )
  end

  def fill_in_points points
    script = '$("#points_slider").slider("value", ' + (points.to_i * 10).to_s + ")"
    page.evaluate_script(script)
  end

  def fill_in_supporting_content(text)
    page.execute_script("$('#supporting_content_editor').focus().html('#{text}').blur()")
  end

  def fill_in_valid_form_entries options = {}
    click_answer = options[:click_answer] || 1
    question_type = options[:question_type] || Tile::QUIZ
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE

    choose_question_type_and_subtype question_type, question_subtype

    fake_upload_image  img_file1
    fill_in_image_credit "by Society"
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in_supporting_content("Ten pounds of cheese. Yes? Or no?")

    fill_in_question "Who rules?"

    2.times { click_add_answer }

    fill_in_answer_field 0, "Me"
    fill_in_answer_field 1, "You"
    fill_in_answer_field 2, "Hipster"

    click_answer.times { select_correct_answer 2 } if question_type == Tile::QUIZ

    fill_in_points "18"

    fill_in_external_link_field  "http://www.google.com/foobar"
  end

  def click_edit_link
    click_here_link[1].click
  end

  def click_create_button
    click_button "Save tile"
  end

  def choose_question_type_and_subtype question_type, question_subtype
    page.find("##{question_type.downcase}.type").click
    page.find(".subtype.#{question_type.downcase}.#{question_subtype}").click
  end


  def create_good_tile
    fill_in_valid_form_entries
    click_create_button
  end

  def create_existing_tiles(demo, status, num)
    FactoryGirl.create_list :tile, num, demo: demo, status: status
  end

  def have_first_tile(tile, status)
    have_selector ".#{status}[data-tile-id='#{tile.id}']"
  end

  def expect_current_tile_id(tile)
     expect(page.find('.tile_holder')["data-current-tile-id"]).to eq(tile.id.to_s)
  end

  def new_tile_placeholder_text
    "Add New Tile"
  end

  def click_add_new_tile
    page.find('#add_new_tile').click
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
    page.all('.js-tile-answer-container')[index]
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
      expect(page).not_to have_css("a.show_more_tiles")
    else
      expect(page).to have_css("a.show_more_tiles")
    end
  end

  def expect_thumbnail_count(expected_count, tile_wrapper='.tile-wrapper')
    expect(page.all(tile_wrapper).size).to eq(expected_count)
  end

  def expect_placeholder_count(expected_count)
    expect(page.all('.placeholder_tile').size).to eq(expected_count)
  end

  def attach_tile locator, path
    page.execute_script("$('#tile_image').css('display','block')")
    attach_file locator, path
  end

  def show_tile_image
    expect(page).to have_selector('img.tile_image', visible: true)
    expect(page).to have_selector('.image_placeholder', visible: false)
  end

  def show_tile_image_placeholder
    expect(page).to have_selector('img.tile_image', visible: false)
    expect(page).to have_selector('.image_placeholder', visible: true)
  end

  def completed_tiles_number
    page.find("#completed_tiles_num", :visible => false).text.to_i
  end

  def total_points
    page.find("#total_points").text.to_i
  end

  def tile_manager_nav
    page.find("#tile_manager_nav")
  end

  def have_tile_manager_nav
    expect(page).to have_selector('#tile_manager_nav')
  end

  def have_no_tile_manager_nav
    expect(page).not_to have_selector('#tile_manager_nav')
  end


  def fake_upload_image filename
    uri = URI.join('file:///', "#{Rails.root}/spec/support/fixtures/tiles/#{filename}")
    url = uri.path
    page.execute_script("$('#remote_media_url').val('#{url}');")
    page.execute_script("$('#upload_preview').attr('src', '#{url}');")
  end

    def img_file1
      "cov1.jpg"
    end

    def img_file2
      "cov2.jpg"
    end

end
