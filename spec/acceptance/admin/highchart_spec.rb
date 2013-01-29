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

  # Highcharts assigns the same class to x and y axis labels, but that's okay because we only need to check the x axis
  def x_axis
    find('.highcharts-axis-labels')
  end

  def points
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
      acts_hash = {}

      # Days with activities in them
      day_12_25 = Highchart.convert_date('12/25/2012')
      day_12_29 = Highchart.convert_date('12/29/2012')
      day_12_31 = Highchart.convert_date('12/31/2012')
      day_1_1   = Highchart.convert_date('1/1/2013')
      day_1_2   = Highchart.convert_date('1/2/2013')
      day_1_16  = Highchart.convert_date('1/16/2013')

      # All 4 create multiple -----------------------------------------
      day_12_25_john_3   = FactoryGirl.create_list :act, 3, demo: demo, created_at: day_12_25, user: john
      day_12_25_paul_2   = FactoryGirl.create_list :act, 2, demo: demo, created_at: day_12_25, user: paul
      day_12_25_george_5 = FactoryGirl.create_list :act, 5, demo: demo, created_at: day_12_25, user: george
      day_12_25_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_25, user: ringo

      acts_hash[day_12_25] = day_12_25_john_3 + day_12_25_paul_2 + day_12_25_george_5 + day_12_25_ringo_1

      # All 4 create one each -----------------------------------------
      day_12_29_john_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: john
      day_12_29_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: paul
      day_12_29_george_1 = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: george
      day_12_29_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_29, user: ringo

      acts_hash[day_12_29] = day_12_29_john_1 + day_12_29_paul_1 + day_12_29_george_1 + day_12_29_ringo_1

      # 2 create multiple and 1 creates 1 ----------------------------------------------
      day_12_31_john_4   = FactoryGirl.create_list :act, 4, demo: demo, created_at: day_12_31, user: john
      day_12_31_paul_4   = FactoryGirl.create_list :act, 4, demo: demo, created_at: day_12_31, user: paul
      day_12_31_george_1 = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_12_31, user: george

      acts_hash[day_12_31] = day_12_31_john_4 + day_12_31_paul_4 + day_12_31_george_1

      # 1 creates multiple and 1 creates 1 -------------------------------
      day_1_1_john_5   = FactoryGirl.create_list :act, 5, demo: demo, created_at: day_1_1, user: john
      day_1_1_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_1, user: paul

      acts_hash[day_1_1] = day_1_1_john_5 + day_1_1_paul_1

      # 1 creates multiple -------------------------------
      day_1_2_george_3 = FactoryGirl.create_list :act, 3, demo: demo, created_at: day_1_2, user: george

      acts_hash[day_1_2] = day_1_2_george_3

      # 1 creates 1 -------------------------------
      day_1_16_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1_16, user: ringo

      acts_hash[day_1_16] = day_1_16_ringo_1
    end

    # -------------------------------------------------

    scenario 'Daily' do
      check 'Total activity'
      check 'Unique users'

      set_start_date start_date
      set_end_date end_date

      set_plot_interval 'Daily'
      set_label_points 'All points'

      click_button 'Show'

      # Put these statements in for debugging screenshots. Need to sleep for a bit to give lines time to be drawn.
      #sleep 1
      #show_me_some_love

      title.should have_content 'Talk to the Duck'
      subtitle.should have_content "#{date_subtitle(start_date)} through #{date_subtitle(end_date)} : By Day"

      legend.should have_content 'Acts'
      legend.should have_content 'Users'

      # Make sure the day labels are correct (both content and format) and that days outside the range are not present
      ['Dec. 26', 'Dec. 30', 'Jan. 01', 'Jan. 15'].each { |day| x_axis.should     have_content day }
      ['Dec. 20', 'Dec. 24', 'Jan. 17', 'Jan. 18'].each { |day| x_axis.should_not have_content day }

      %w(4 11 9 6 3).each { |y| points.should have_content y }

      uncheck 'Total activity'
      click_button 'Show'
      legend.should_not have_content 'Acts'
      legend.should     have_content 'Users'

      check 'Total activity'
      uncheck 'Unique users'
      click_button 'Show'
      legend.should     have_content 'Acts'
      legend.should_not have_content 'Users'
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
