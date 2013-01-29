require 'acceptance/acceptance_helper'

# NOTE: Need to run these specs using 'webkit', not (the default) 'poltergeist'
#       since the latter seems to not run any javascript.

feature 'Highchart Plot' do
  let(:demo)   { FactoryGirl.create :demo, name: 'Talk to the Duck' }
  let(:admin)  { FactoryGirl.create :site_admin, demo: demo }

  # Pick days that not only straddle a month, but a year as well
  let(:start_date) { '12/25/2012' }
  let(:end_date)   { '01/16/2013' }

  # -------------------------------------------------

  def set_start_date(date)
    fill_in 'chart_start_date', with: date
  end

  def set_end_date(date)
    fill_in 'chart_end_date', with: date
  end

  def set_plot_interval(interval)
    select interval, from: 'chart_interval'
  end

  def set_label_points(label)
    select label, from: 'chart_label_points'
  end

  def title
    find('.highcharts-title')
  end

  def subtitle
    find('.highcharts-subtitle')
  end

  def legend
    find('.highcharts-legend')
  end

  def x_axis
    find('.highcharts-legend + .highcharts-axis-labels')
  end

  def act_labels
    find('.highcharts-data-labels')
  end

  def user_labels
    # If acts and users are both plotted the 1st set of labels is always for the acts and the 2nd is always for the users
    page.has_css?('.highcharts-data-labels', count: 2) ? find('.highcharts-data-labels + .highcharts-data-labels') :
                                                         find('.highcharts-data-labels')
  end

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
    click_link "Admin"
  end

  # -------------------------------------------------

  context 'Controls Only (No Plotted Points)', js: :webkit  do
    def start_date_value
      find('#chart_start_date').value
    end

    def end_date_value
      find('#chart_end_date').value
    end

    def total_activity
      find '#chart_plot_acts'
    end

    def unique_users
      find '#chart_plot_users'
    end

    def interval_should_be(interval)
      page.should have_select 'chart_interval', selected: interval
    end

    def label_should_be(label)
      page.should have_select 'chart_label_points', selected: label
    end

    def should_be_error_message(boolean = true)
      err_msg = 'You did not supply the necessary plot parameters. Please check and try again.'
      boolean ? (page.should have_content(err_msg)) : (page.should_not have_content(err_msg))
    end

    # -------------------------------------------------

    scenario 'Control Initialization and Retaining Values' do
      # Initial state
      total_activity.checked?.should be_false
      unique_users.checked?.should be_false

      start_date_value.should be_blank
      end_date_value.should be_blank

      interval_should_be 'Weekly'
      label_should_be 'All points'

      # Interact with the controls
      check 'Total activity'
      check 'Unique users'

      set_start_date(start_date)
      set_end_date(end_date)

      set_plot_interval 'Daily'
      set_label_points 'Every other'

      click_button 'Show'

      # Controls should reflect most-recent selections
      total_activity.checked?.should be_true
      unique_users.checked?.should be_true

      start_date_value.should == start_date
      end_date_value.should == end_date

      interval_should_be 'Daily'
      label_should_be 'Every other'

      # And finally, make sure page contains the highchart-button to save chart to an image file
      page.should have_selector '#exportButton'
    end

    # -------------------------------------------------

    # Basically, start- and end-dates should be kept in synch when in 'Hourly' mode (only)
    scenario 'Date Control Synchronization' do
      set_plot_interval 'Weekly'
      set_start_date(start_date)
      end_date_value.should be_blank

      set_plot_interval 'Daily'
      end_date_value.should be_blank

      set_plot_interval 'Hourly'
      end_date_value.should == start_date

      set_start_date(end_date)
      end_date_value.should == end_date

      set_end_date(start_date)
      start_date_value.should == start_date

      set_plot_interval 'Weekly'
      set_end_date(end_date)
      start_date_value.should == start_date
    end

    # -------------------------------------------------

    # Let them know if they did not supply enough parameters to plot something
    scenario 'Error Message' do
      click_button 'Show'
      should_be_error_message

      set_start_date(start_date)
      click_button 'Show'
      should_be_error_message

      set_end_date(end_date)
      click_button 'Show'
      should_be_error_message

      check 'Total activity'
      click_button 'Show'
      should_be_error_message(false)
    end
  end

  # -------------------------------------------------

  # The basic (and big) problem is that Capybara does not recognize non-html tags, i.e. all of the svg tags in the plot.
  # We can, however, test the label values on the points. But in order to know if we have "selected" the correct points,
  # the set of points (i.e. y values) for acts and users must be mutually exclusive. Even to the point of no intersection
  # of numerals, e.g. an '11' for acts is not allowed because there is a '1' for users. ^%$#@!

  context 'Plotted Points', js: :webkit  do
    let(:john)   { FactoryGirl.create :user, demo: demo }
    let(:paul)   { FactoryGirl.create :user, demo: demo }
    let(:george) { FactoryGirl.create :user, demo: demo }
    let(:ringo)  { FactoryGirl.create :user, demo: demo }

    def date_subtitle(date)
      Highchart.convert_date(date).to_s(:chart_subtitle_range)
    end

    # -------------------------------------------------

    background do
      # Days with activities in them
      day_12_25 = Highchart.convert_date('12/25/2012')
      day_12_29 = Highchart.convert_date('12/29/2012')
      day_12_31 = Highchart.convert_date('12/31/2012')
      day_1_1   = Highchart.convert_date('1/1/2013')
      day_1_2   = Highchart.convert_date('1/2/2013')
      day_1_16  = Highchart.convert_date('1/16/2013')

      # All 4 create multiple -----------------------------------------
      FactoryGirl.create_list :act, 3, demo: demo, created_at: day_12_25, user: john
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_25, user: paul
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_25, user: george
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_25, user: ringo

      # 3 create 1 and 1 creates multiple -----------------------------------------
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: john
      FactoryGirl.create_list :act, 4, demo: demo, created_at: day_12_29, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: george
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: ringo

      # 2 create multiple and 1 creates 1 ----------------------------------------------
      FactoryGirl.create_list :act, 4, demo: demo, created_at: day_12_31, user: john
      FactoryGirl.create_list :act, 4, demo: demo, created_at: day_12_31, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_31, user: george

      # 1 creates multiple and 1 creates 1 -------------------------------
      FactoryGirl.create_list :act, 5, demo: demo, created_at: day_1_1, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_1, user: paul

      # 1 creates multiple -------------------------------
      FactoryGirl.create_list :act, 8, demo: demo, created_at: day_1_2, user: george

      # 2 create multiple -------------------------------
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_16, user: john
      FactoryGirl.create_list :act, 3, demo: demo, created_at: day_1_16, user: ringo
    end

    # When all is said and done:
    #
    # 12/25: 9 acts by 4 users
    # 12/29: 7 acts by 4 users
    # 12/31: 9 acts by 3 users
    # 1/1:   6 acts by 2 users
    # 1/2:   8 acts by 1 users
    # 12/25: 5 acts by 2 users
    # -------------------------------------------------

    scenario 'Daily' do
      check 'Total activity'
      check 'Unique users'

      set_start_date start_date
      set_end_date   end_date

      set_plot_interval 'Daily'
      set_label_points 'All points'

      click_button 'Show'

      # Put these statements in for debugging screenshots. (Need to sleep for a bit to give lines time to be drawn.)
      #sleep 1
      #show_me_some_love

      title.should have_content "H Engage Chart For #{demo.name}"
      subtitle.should have_content "#{date_subtitle(start_date)} through #{date_subtitle(end_date)} : By Day"

      legend.should have_content 'Acts'
      legend.should have_content 'Users'

      # Make sure the day labels are correct (both content and format) and that days outside the range are not present
      ['Dec. 26', 'Dec. 30', 'Jan. 01', 'Jan. 15'].each { |day| x_axis.should     have_content day }
      ['Dec. 20', 'Dec. 24', 'Jan. 17', 'Jan. 18'].each { |day| x_axis.should_not have_content day }

      # Many 0's exist for both acts and users
      act_labels.should  have_content '0'
      user_labels.should have_content '0'

      # Make sure no invalid points (within reason, of course)
      %w(10 11 12).each { |y| act_labels.should_not  have_content y }
      %w(5 6 7).each    { |y| user_labels.should_not have_content y }

      # Valid points, i.e. labels
      act_points  = %w(5 6 7 8 9)
      user_points = %w(1 2 3 4)

      act_points.each  { |y| act_labels.should  have_content y }
      user_points.each { |y| user_labels.should have_content y }

      uncheck 'Total activity'
      click_button 'Show'

      legend.should_not have_content 'Acts'
      legend.should     have_content 'Users'

      act_points.each  { |y| act_labels.should_not have_content y }
      user_points.each { |y| user_labels.should    have_content y }

      check 'Total activity'
      uncheck 'Unique users'
      click_button 'Show'

      legend.should     have_content 'Acts'
      legend.should_not have_content 'Users'

      act_points.each  { |y| act_labels.should      have_content y }
      user_points.each { |y| user_labels.should_not have_content y }

      check 'Total activity'
      uncheck 'Unique users'

      set_label_points 'Every other'
      click_button 'Show'

      %w(5 7 8 9).each  { |y| act_labels.should      have_content y }
      %w(6).each        { |y| act_labels.should_not  have_content y }

      uncheck 'Total activity'
      check   'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      show_me_some_love

      set_label_points 'Every other'
      click_button 'Show'

      show_me_some_love

      #%w(5 7 8 9).each  { |y| act_labels.should      have_content y }
      #%w(6).each        { |y| act_labels.should_not  have_content y }

    end

    #scenario 'Plots' do
    #
    #end
    #
    #scenario 'Point Values' do
    #
    #end
    #
    #scenario 'Point Labels' do
    #
    #end
    #
    #scenario 'X-Axis Labels' do
    #
    #end
  end
end
