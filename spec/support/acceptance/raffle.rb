module RaffleHelpers
  #
  # => Client Admin Side
  #
  def click_save_draft
    page.find("#save_draft").click
  end

  def to_start_date date
    if date.class == DateTime
      date = to_calendar_format date
    end
    DateTime.strptime(date + " 00:00", "%m/%d/%Y %H:%M").change(:offset => "-0400")
  end

  def to_end_date date
    if date.class == DateTime
      date = to_calendar_format date
    end
    DateTime.strptime(date + " 23:59", "%m/%d/%Y %H:%M").change(:offset => "-0400")
  end

  def to_calendar_format date
    date.strftime("%m/%d/%Y")
  end

  def fill_in_start_date text
    page.find("#raffle_starts_at").set(text)
  end

  def fill_in_end_date text
    page.find("#raffle_ends_at").set(text)
  end

  def fill_in_prize index, text
    page.all(".prize_field")[index].set(text)
  end

  def click_add_prize
    page.find(".add_another").click
  end

  def fill_in_other_info text
    page.find("#raffle_other_info").set(text)
  end

  def fill_prize_form
    start_date = to_calendar_format(DateTime.now)
    end_date = to_calendar_format(DateTime.now + 7.days)

    fill_in_start_date start_date
    fill_in_end_date end_date
    fill_in_other_info "Other info"
    click_add_prize
    click_add_prize
    fill_in_prize 0, "Prize2"
    fill_in_prize 1, "Prize3"
  end

  def click_start_raffle
    page.find("#start").click
  end

  def click_clear_form
    page.find(".clear_form").click
    click_button "Confirm"
  end

  def click_edit_raffle
    page.find("#edit_or_save").click
  end

  def click_save_live_raffle
    page.find("#edit_or_save").click
  end

  def click_cancel_raffle
    page.find('#cancel_raffle').click
    click_link "Confirm?"
  end

  def click_link_end_early
    click_link "End Early"
    click_link "Confirm?"
  end

  def click_pick_winners number
    page.find("#number_of_winners").set(number)
    page.find("#pick_winners input[type=submit]").click
  end

  def delete_winner index
    page.all("td.winner_delete")[index].click
  end

  def winner_email index
    page.all("td.winner_email")[index].text
  end

  def repick_winner index
    page.all("td.winner_repick")[index].click
  end

  #
  # => User Side
  #

  def expect_raffle_progress percents
    percents *= 2 #convertion
    page.should have_selector(".progress-" + percents.to_s)
  end

  def expect_reffle_entries tickets
    page.find("#raffle_entries").text.should == tickets.to_s
  end

  def click_raffle_info
    page.find("#raffle_info").click
  end
end
