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

  # The basic - and big - problem is that Capybara does not recognize non-html tags, i.e. all of the svg tags in the plot.
  # We can, however, test the label values on the points. But in order to know if we have "selected" the correct points,
  # the set of points (i.e. y values) for acts and users must be mutually exclusive - even to the point of no intersection
  # of numerals, e.g. an '11' for acts is not allowed because there is a '1' for users. ^%$#@!

  context 'Plotted Points', js: :webkit  do
    let(:john)   { FactoryGirl.create :user, demo: demo }
    let(:paul)   { FactoryGirl.create :user, demo: demo }
    let(:george) { FactoryGirl.create :user, demo: demo }
    let(:ringo)  { FactoryGirl.create :user, demo: demo }

    def title
      find('.highcharts-title')
    end

    def subtitle
      find('.highcharts-subtitle')
    end

    def date_in_subtitle(date)
      Highchart.convert_date(date).to_s(:chart_subtitle_range)
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

    def acts_in_plot(boolean)
      if boolean
        legend.should have_content 'Acts'
        @valid_act_points.each { |y| act_labels.should have_content y }
      else
        legend.should_not have_content 'Acts'
        @valid_act_points.each { |y| act_labels.should_not have_content y }
      end
    end

    def users_in_plot(boolean)
      if boolean
        legend.should have_content 'Users'
        @valid_user_points.each { |y| user_labels.should have_content y }
      else
        legend.should_not have_content 'Users'
        @valid_user_points.each { |y| user_labels.should_not have_content y }
      end
    end

    def no_invalid_points_in_plot  # Within reason, of course
      @invalid_act_points.each  { |y| act_labels.should_not  have_content y }
      @invalid_user_points.each { |y| user_labels.should_not have_content y }
    end

    # Redefine to give time for plotted lines to appear in both the screenshot and webpage
    def show_me_some_love
      sleep 1
      super
    end

    # -------------------------------------------------
    scenario 'Daily - everything except labelling every other point' do
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

      # When all is said and done - set as instance variables tests implemented by helper methods
      # (Remember, these two groups of numbers must be mutually exclusive in order for the tests to work)
      #
      # 12/25: 9 acts by 4 users
      # 12/29: 7 acts by 4 users
      # 12/31: 9 acts by 3 users
      # 1/1:   6 acts by 2 users
      # 1/2:   8 acts by 1 users
      # 12/25: 5 acts by 2 users

      @valid_act_points  = %w(5 6 7 8 9)
      @valid_user_points = %w(1 2 3 4)

      @invalid_act_points  = %w(10 11 12)
      @invalid_user_points = %w(5 6 7)

      # -------------------------------------------------

      check 'Total activity'
      check 'Unique users'

      set_start_date start_date
      set_end_date   end_date

      set_plot_interval 'Daily'
      set_label_points 'All points'

      click_button 'Show'

      title.should have_content "H Engage Chart For #{demo.name}"
      subtitle.should have_content "#{date_in_subtitle(start_date)} through #{date_in_subtitle(end_date)} : By Day"

      legend.should have_content 'Acts'
      legend.should have_content 'Users'

      # Make sure the day labels are correct (both content and format) and that days outside the range are not present
      ['Dec. 26', 'Dec. 30', 'Jan. 01', 'Jan. 15'].each { |day| x_axis.should     have_content day }
      ['Dec. 20', 'Dec. 24', 'Jan. 17', 'Jan. 18'].each { |day| x_axis.should_not have_content day }

      # Many 0's exist for both acts and users
      act_labels.should  have_content '0'
      user_labels.should have_content '0'

      no_invalid_points_in_plot

      acts_in_plot(true)
      users_in_plot(true)

      uncheck 'Total activity'
      check 'Unique users'
      click_button 'Show'

      acts_in_plot(false)
      users_in_plot(true)

      check 'Total activity'
      uncheck 'Unique users'
      click_button 'Show'

      acts_in_plot(true)
      users_in_plot(false)
    end

    scenario 'Daily - labelling every other point' do
      # New start and end dates for this test
      start_date = '11/11/2012'
      end_date   = '11/16/2012'

      # Days with activities in them
      day_11_11 = Highchart.convert_date('11/11/2012')
      day_11_12 = Highchart.convert_date('11/12/2012')
      day_11_13 = Highchart.convert_date('11/13/2012')
      day_11_14 = Highchart.convert_date('11/14/2012')
      day_11_15 = Highchart.convert_date('11/15/2012')
      day_11_16 = Highchart.convert_date('11/16/2012')

      # 4 create 8 -----------------------------------------
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_11, user: john
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_11, user: paul
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_11, user: george
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_11, user: ringo

      # 3 create 7 -----------------------------------------
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_12, user: john
      FactoryGirl.create_list :act, 4, demo: demo, created_at: day_11_12, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_12, user: george

      # 2 create 6 ----------------------------------------------
      FactoryGirl.create_list :act, 3, demo: demo, created_at: day_11_13, user: george
      FactoryGirl.create_list :act, 3, demo: demo, created_at: day_11_13, user: ringo

      # 1 creates 5 -------------------------------
      FactoryGirl.create_list :act, 5, demo: demo, created_at: day_11_14, user: john

      # 4 create 4 -----------------------------------------
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_15, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_15, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_15, user: george
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_15, user: ringo

      # 2 create 3 -------------------------------
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_11_16, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_11_16, user: ringo

      # When all is said and done - set as instance variables tests implemented by helper methods
      # (These 2 sets of numbers do *not* have to be mutually exclusive in order for the tests to work)
      # 11/11: 8 acts by 4 users
      # 11/12: 7 acts by 3 users
      # 11/13: 6 acts by 2 users
      # 11/14: 5 acts by 1 users
      # 11/15: 4 acts by 4 users
      # 11/16: 3 acts by 2 users

      # ----------------------------------------

      set_start_date start_date
      set_end_date   end_date

      set_plot_interval 'Daily'

      check 'Total activity'
      uncheck 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for 1..8
      3.step(8, 1) { |y| act_labels.should have_content y.to_s }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 4, 6, 8 ; No labels for 3, 5, 7
      4.step(8, 2) { |y| act_labels.should     have_content y.to_s }
      3.step(8, 2) { |y| act_labels.should_not have_content y.to_s }

      uncheck 'Total activity'
      check 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for 1..4
      1.step(4, 1) { |y| user_labels.should have_content y.to_s }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 2, 4 ; No labels for 1, 3
      2.step(4, 2) { |y| user_labels.should     have_content y.to_s }
      1.step(4, 2) { |y| user_labels.should_not have_content y.to_s }
    end

    # The weekly plot gets a little confusing, so here's a visual representation of what we are dealing with.
    # Remember, the range is Dec. 25 thru Jan 16. These days were picked to not only straddle both a month
    # and a year, but to test the weekly view's "problem end points."
    #
    # Specifically, the plot points and ranges are:
    # Week 1: Dec 25 thru Dec 31 ; Dec 25 should contain 9 acts (25 - 3, 26 - 2, 29 - 3, 31 - 1)
    # Week 2: Jan 1 thru Jan 7   ; Jan 1 should contain 8 acts (1 - 2, 2 - 2, 3 - 2, 7 - 2)
    # Week 3: Jan 8 thru Jan 14  ; Jan 8 should contain 6 acts (8 - 3, 14 - 3)
    # Week 4: Jan 15 thru Jan 16 ; Jan 15 should contain 5 acts (15 - 3, 16 - 2)
    #
    # This ensures that we test a last-plotted-point (Jan 15) occurring before the end date of the range
=begin
        DECEMBER 2012
Su	Mo	Tu	We	Th	Fr	Sa
23	24	25	26	27	28	29
30	31  1   2   3   4   5
        JANUARY 2013
Su	Mo	Tu	We	Th	Fr	Sa
30  31  1	  2	  3	  4	  5
6	  7	  8	  9	  10	11	12
13	14	15	16	17	18	19
=end
    scenario 'Weekly - everything including labelling every other point' do
      # Week 1
      day_12_25 = Highchart.convert_date('12/25/2012')
      day_12_26 = Highchart.convert_date('12/26/2012')
      day_12_29 = Highchart.convert_date('12/29/2012')
      day_12_31 = Highchart.convert_date('12/31/2012')

      # Week 2
      day_1_1 = Highchart.convert_date('1/1/2013')
      day_1_2 = Highchart.convert_date('1/2/2013')
      day_1_3 = Highchart.convert_date('1/3/2013')
      day_1_7 = Highchart.convert_date('1/7/2013')

      # Week 3
      day_1_8 = Highchart.convert_date('1/8/2013')
      day_1_14 = Highchart.convert_date('1/14/2013')

      # Week 4
      day_1_15 = Highchart.convert_date('1/15/2013')
      day_1_16 = Highchart.convert_date('1/16/2013')

      # Week 1: Dec 25 thru Dec 31 : 25 - 3, 26 - 2, 29 - 3, 31 - 1
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_25, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_25, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_25, user: george

      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_26, user: ringo

      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: george
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_29, user: ringo

      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_31, user: george

      # Week 2: Jan 1 thru Jan 7 : 1 - 2, 2 - 2, 3 - 2, 7 - 2
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_1, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_1, user: paul

      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_2, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_2, user: george

      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_3, user: paul

      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_7, user: george

      # Week 3: Jan 8 thru Jan 14 : 8 - 3, 14 - 3
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_8, user: john
      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_8, user: ringo

      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_14, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_14, user: ringo

      # Week 4: Jan 15 thru Jan 16 ; Jan 15 should contain 5 acts (15 - 3, 16 - 2)
      FactoryGirl.create_list :act, 3, demo: demo, created_at: day_1_15, user: paul

      FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1_16, user: paul

      # When all is said and done - set as instance variables tests implemented by helper methods
      # (Remember, these two groups of numbers must be mutually exclusive in order for the tests to work)
      #
      # 12/25: 9 acts by 4 users
      # 1/1:   8 acts by 3 users
      # 1/8:   6 acts by 2 users
      # 1/15:  5 acts by 1 users

      @valid_act_points  = %w(5 6 8 9)
      @valid_user_points = %w(1 2 3 4)

      @invalid_act_points  = %w(2 4 11)
      @invalid_user_points = %w(5 6 7)

      # -------------------------------------------------

      check 'Total activity'
      check 'Unique users'

      set_start_date start_date
      set_end_date   end_date

      set_plot_interval 'Weekly'
      set_label_points 'All points'

      click_button 'Show'

      title.should have_content "H Engage Chart For #{demo.name}"
      subtitle.should have_content "#{date_in_subtitle(start_date)} through #{date_in_subtitle(end_date)} : By Week"

      legend.should have_content 'Acts'
      legend.should have_content 'Users'

      # Make sure the day labels are correct (both content and format) and that days outside the range are not present
      ['Dec. 26', 'Dec. 30', 'Jan. 01', 'Jan. 15'].each { |day| x_axis.should     have_content day }
      ['Dec. 20', 'Dec. 24', 'Jan. 17', 'Jan. 18'].each { |day| x_axis.should_not have_content day }

      # Aren't any 0's in this plot
      act_labels.should_not  have_content '0'
      user_labels.should_not have_content '0'

      no_invalid_points_in_plot

      acts_in_plot(true)
      users_in_plot(true)

      uncheck 'Total activity'
      check 'Unique users'
      click_button 'Show'

      acts_in_plot(false)
      users_in_plot(true)

      check 'Total activity'
      uncheck 'Unique users'
      click_button 'Show'

      acts_in_plot(true)
      users_in_plot(false)

      # Now check out labelling every other point...

      check 'Total activity'
      uncheck 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for all values
      @valid_act_points.each { |y| act_labels.should have_content y }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 6, 9 ; No labels for 5, 8
      %w(6 9).each { |y| act_labels.should     have_content y }
      %w(5 8).each { |y| act_labels.should_not have_content y }

      uncheck 'Total activity'
      check 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for all values
      @valid_user_points.each { |y| user_labels.should have_content y }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 2, 4 ; No labels for 1, 3
      %w(2 4).each { |y| user_labels.should     have_content y }
      %w(1 3).each { |y| user_labels.should_not have_content y }
    end

    scenario 'Hourly - everything including labelling every other point' do
      end_date = start_date  # This is how the app behaves in real life in hourly mode

      start_boundary = Highchart.convert_date(start_date).beginning_of_day
      end_boundary   = Highchart.convert_date(end_date).end_of_day

      # Hours with activities in them
      hour_1 = start_boundary + 1.hours + 1.minute
      hour_2 = start_boundary + 2.hours + 1.minute
      hour_3 = start_boundary + 3.hours + 1.minute

      hour_20 = end_boundary - 3.hours - 1.minute
      hour_21 = end_boundary - 2.hours - 1.minute
      hour_22 = end_boundary - 1.hours - 1.minute

      # All 4 create multiple -----------------------------------------
      FactoryGirl.create_list :act, 3, demo: demo, created_at: hour_1, user: john
      FactoryGirl.create_list :act, 2, demo: demo, created_at: hour_1, user: paul
      FactoryGirl.create_list :act, 2, demo: demo, created_at: hour_1, user: george
      FactoryGirl.create_list :act, 2, demo: demo, created_at: hour_1, user: ringo

      # 3 create 1 and 1 creates multiple -----------------------------------------
      FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: john
      FactoryGirl.create_list :act, 4, demo: demo, created_at: hour_2, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: george
      FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: ringo

      # 2 create multiple and 1 creates 1 ----------------------------------------------
      FactoryGirl.create_list :act, 4, demo: demo, created_at: hour_3, user: john
      FactoryGirl.create_list :act, 4, demo: demo, created_at: hour_3, user: paul
      FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_3, user: george

      # 1 creates multiple and 1 creates 1 -------------------------------
      FactoryGirl.create_list :act, 5, demo: demo, created_at: hour_20, user: john
      FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_20, user: paul

      # 1 creates multiple -------------------------------
      FactoryGirl.create_list :act, 8, demo: demo, created_at: hour_21, user: george

      # 2 create multiple -------------------------------
      FactoryGirl.create_list :act, 2, demo: demo, created_at: hour_22, user: john
      FactoryGirl.create_list :act, 3, demo: demo, created_at: hour_22, user: ringo

      # When all is said and done - set as instance variables tests implemented by helper methods
      # (Remember, these two groups of numbers must be mutually exclusive in order for the tests to work)
      #
      # hour 1:  9 acts by 4 users
      # hour 2:  7 acts by 4 users
      # hour 3:  9 acts by 3 users
      # hour 20: 6 acts by 2 users
      # hour 21: 8 acts by 1 users
      # hour 22: 5 acts by 2 users

      @valid_act_points  = %w(5 6 7 8 9)
      @valid_user_points = %w(1 2 3 4)

      @invalid_act_points  = %w(10 11 12)
      @invalid_user_points = %w(5 6 7)

      # -------------------------------------------------

      check 'Total activity'
      check 'Unique users'

      set_start_date start_date
      set_end_date   end_date

      set_plot_interval 'Hourly'
      set_label_points 'All points'

      click_button 'Show'

      title.should have_content "H Engage Chart For #{demo.name}"
      subtitle.should have_content "#{Highchart.convert_date(start_date).to_s(:chart_subtitle_one_day)} : By Hour"

      legend.should have_content 'Acts'
      legend.should have_content 'Users'

      # Make sure the hour labels are correct (both content and format) and that no date info is on the axis
      ['12 AM', '4 AM', '8 AM', '12 PM', '4 PM', '8 PM'].each { |day| x_axis.should have_content day }
      ['Dec. 25', 'Dec.', '25',].each { |day| x_axis.should_not have_content day }

      # Many 0's exist for both acts and users
      act_labels.should  have_content '0'
      user_labels.should have_content '0'

      no_invalid_points_in_plot

      acts_in_plot(true)
      users_in_plot(true)

      uncheck 'Total activity'
      check 'Unique users'
      click_button 'Show'

      acts_in_plot(false)
      users_in_plot(true)

      check 'Total activity'
      uncheck 'Unique users'
      click_button 'Show'

      acts_in_plot(true)
      users_in_plot(false)

      # Now check out labelling every other point...

      check 'Total activity'
      uncheck 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for all values
      @valid_act_points.each { |y| act_labels.should have_content y }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 5, 6, 7 ; No labels for 8, 9
      %w(5 6 7).each { |y| act_labels.should     have_content y }
      %w(8 9).each   { |y| act_labels.should_not have_content y }

      uncheck 'Total activity'
      check 'Unique users'

      set_label_points 'All points'
      click_button 'Show'

      # Labels for all values
      @valid_user_points.each { |y| user_labels.should have_content y }

      set_label_points 'Every other'
      click_button 'Show'

      # Labels for 2, 4 ; No labels for 1, 3
      %w(2 4).each { |y| user_labels.should     have_content y }
      %w(1 3).each { |y| user_labels.should_not have_content y }
    end
  end
end
