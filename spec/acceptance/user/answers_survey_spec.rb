require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'User answers survey' do
  before(:each) do
    @fooco = FactoryGirl.create(:demo, name: 'FooCo')
    @barco = FactoryGirl.create(:demo, name: 'BarCo')

    @dan = FactoryGirl.create(:user_with_phone, :claimed, name: 'Dan',  phone_number: '+14155551212', demo: @fooco)
    @vlad = FactoryGirl.create(:user_with_phone, :claimed, name: 'Vlad', phone_number: '+16175551212', demo: @fooco)
    @tom = FactoryGirl.create(:user_with_phone, :claimed, name: 'Tom',  phone_number: '+18085551212', demo: @fooco)
    @bob = FactoryGirl.create(:user_with_phone, :claimed, name: 'Bob',  phone_number: '+14105551212', demo: @fooco)
    @sam = FactoryGirl.create(:user_with_phone, :claimed, name: 'Sam',  phone_number: '+19995551212', demo: @barco)

    @fooco_player_phone_numbers = %w(+14155551212 +16175551212 +18085551212 +14105551212)
    @barco_player_number = '+19995551212'

    @open_time = Time.parse '2011-05-01 11:00'
    @close_time = Time.parse '2011-05-01 21:00'
    @survey = FactoryGirl.create(:survey, name: "FooCo Health Survey", open_at: @open_time, close_at: @close_time, demo: @fooco)

    @q1 = FactoryGirl.create(:survey_question, text: 'Do you smoke crack?', index: 1, survey: @survey)
    @q2 = FactoryGirl.create(:survey_question, text: 'Do you like cheese?', index: 2, points: 5, survey: @survey)
    @q3 = FactoryGirl.create(:survey_question, text: 'How important is doing what you\'re told?', index: 3, survey: @survey)
    1.upto(2) {|i| FactoryGirl.create(:survey_valid_answer, value: i.to_s, survey_question: @q1)}
    1.upto(2) {|i| FactoryGirl.create(:survey_valid_answer, value: i.to_s, survey_question: @q2)}
    1.upto(5) {|i| FactoryGirl.create(:survey_valid_answer, value: i.to_s, survey_question: @q3)}

    @base_time = Time.parse('2011-05-01 13:00')
    @second_prompt_time = @base_time + 2.hours
    @third_prompt_time = @base_time + 4.hours
    @fourth_prompt_time = @base_time + 6.hours

    FactoryGirl.create(:survey_prompt, send_time: @base_time, text: 'Answer this, peon:', survey: @survey)
    FactoryGirl.create(:survey_prompt, send_time: @second_prompt_time, text: 'Answer the remaining %remaining_questions:', survey: @survey)
    FactoryGirl.create(:survey_prompt, send_time: @third_prompt_time, text: 'Answer the remaining %remaining_questions or else:', survey: @survey)
    FactoryGirl.create(:survey_prompt, send_time: @fourth_prompt_time, text: 'This is your last chance to answer these %remaining_questions:', survey: @survey)

    has_password(User.find_by_name('Dan'), 'foobar')
  end

  after(:each) do
    FakeTwilio::SMS.clear_all
    Timecop.return
  end

  scenario "Survey sends first prompt to everyone in the demo" do
    Timecop.freeze(Time.parse("2011-05-01 13:00"))
    crank_dj_clear
    @fooco_player_phone_numbers.each {|player_phone_number| expect_mt_sms player_phone_number, "Answer this, peon: Do you smoke crack?"}
    expect_no_mt_sms(@barco_player_number)
  end

  scenario "Prompt is not sent prematurely" do
    FakeTwilio.sent_messages.should be_empty
    Timecop.freeze(Time.parse("2011-05-01 12:59"))
    crank_dj_clear
    FakeTwilio.sent_messages.should be_empty
  end

  scenario "User can kick off survey by asking for it if survey is open" do
    Timecop.freeze(Time.parse("2011-05-01 12:59:59"))
    crank_dj_clear

    expect_no_mt_sms("+14155551212")

    mo_sms("+14155551212", "survey")
    expect_mt_sms("+14155551212", "Do you smoke crack?")

    mo_sms("+14155551212", "1")
    expect_mt_sms("+14155551212", "Do you like cheese?")
  end

  scenario "User can't kick off survey by asking for it if it's not currently open" do
    Timecop.freeze(@open_time - 1.second)
    mo_sms("+14155551212", "survey")
    expect_mt_sms("+14155551212", "Sorry, there is not currently a survey open.")

    FakeTwilio::SMS.clear_all
    Timecop.freeze(@close_time + 1.second)
    mo_sms("+14155551212", "survey")
    expect_mt_sms("+14155551212", "Sorry, there is not currently a survey open.")
  end

  scenario "Second prompt send to everyone in the demo who hasn't answered every question" do
    Timecop.freeze(@second_prompt_time)
    [@q1, @q2, @q3].each {|question| FactoryGirl.create(:survey_answer, user: @dan, survey_question: question)}
    [@q1, @q2].each {|question| FactoryGirl.create(:survey_answer, user: @vlad, survey_question: question)}
    [@q1].each {|question| FactoryGirl.create(:survey_answer, user: @tom, survey_question: question)}
    crank_dj_clear

    expect_mt_sms(@vlad.phone_number, "Answer the remaining question: How important is doing what you're told?")
    expect_mt_sms(@tom.phone_number, "Answer the remaining 2 questions: Do you like cheese?")
    expect_mt_sms(@bob.phone_number, "Answer the remaining 3 questions: Do you smoke crack?")
    expect_no_mt_sms(@dan.phone_number)
    expect_no_mt_sms(@sam.phone_number)
  end

  scenario "No questions from old surveys show up" do
    new_open_time = @open_time + 1.month
    new_close_time = new_open_time + 1.hour

    new_survey = FactoryGirl.create(:survey, open_at: new_open_time, close_at: new_close_time, demo: @fooco)

    [
      "Where are the snowfalls of yesteryear?",
      "What's the matter with kids these days?",
      "Whither Canada?"
    ].each_with_index do |text, i|
      FactoryGirl.create(:survey_question, text: text, index: (i + 1), survey: new_survey)
    end

    first_new_question = SurveyQuestion.find_by_text("Where are the snowfalls of yesteryear?")
    FactoryGirl.create(:survey_valid_answer, value: '1', survey_question: first_new_question)

    Timecop.freeze(Time.parse("2011-06-01 15:00 UTC"))
    mo_sms(@dan.phone_number, "1")
    expect_mt_sms(@dan.phone_number, "What's the matter with kids these days?")
    expect_no_mt_sms_including(@dan.phone_number, "How much do you like stuff?")
  end

  scenario "Answers from old surveys don't count against current survey" do
    old_open_at = @base_time - 1.year
    old_close_at = old_open_at + 1.hour
    old_survey = FactoryGirl.create(:survey, open_at: old_open_at, close_at: old_close_at, demo: @fooco)

    [
      "Where are the snowfalls of yesteryear?",
      "What's the matter with kids these days?",
      "Whither Canada?"
    ].each_with_index do |text, i|
      FactoryGirl.create(:survey_question, text: text, index: (i + 1), survey: old_survey)
    end

    first_old_question = SurveyQuestion.find_by_text("Where are the snowfalls of yesteryear?")
    FactoryGirl.create(:survey_valid_answer, value: '1', survey_question: first_old_question)

    FactoryGirl.create(:survey_answer, user: @dan, survey_question: first_old_question)

    Timecop.freeze(@base_time)

    mo_sms(@dan.phone_number, '1')
    expect_mt_sms(@dan.phone_number, @q2.text)
    expect_no_mt_sms_including(@dan.phone_number, @q3.text)
  end

  scenario 'User responds to question during the window with a good value' do
    Timecop.freeze(Time.parse('2011-05-01 15:00 UTC'))
    mo_sms(@dan.phone_number, '1')

    expect_mt_sms(@dan.phone_number, 'Do you like cheese?')

    signin_as(@dan, 'foobar')
    expect_content "Dan answered a survey question"
  end

  scenario 'User responds to question in a demo with a custom answer act message' do
    demo = FactoryGirl.create(:demo, survey_answer_activity_message: 'did the thing')
    fred = FactoryGirl.create(:user, name: 'Fred', phone_number: '+12345551212', demo: demo)
    has_password(fred, 'foobar')
    survey = FactoryGirl.create(:survey, open_at: @base_time, close_at: @base_time + 10.hours, demo: demo)
    question = FactoryGirl.create(:survey_question, text: 'What are pants for?', index: 1, survey: survey)
    [1,2].each {|i| FactoryGirl.create(:survey_valid_answer, value: i.to_s, survey_question: question)}

    Timecop.freeze(@base_time)

    mo_sms(fred.phone_number, '1')
    signin_as(fred, 'foobar')
    expect_content 'Fred did the thing'
  end

  scenario 'User responds to a question with bonus points attached' do
    Timecop.freeze(@base_time)
    FactoryGirl.create(:survey_answer, user: @dan, survey_question: @q1)
    mo_sms(@dan.phone_number, '1')
    
    expect_mt_sms(@dan.phone_number, "How important is doing what you're told?")
    signin_as(@dan, 'foobar')
    expect_content "5 pts Dan answered a survey question less than a minute ago"
  end

  scenario "User responds to question during the window with a bad value that's a single digit" do
    Timecop.freeze(@base_time)
    mo_sms(@dan.phone_number, '3')
    expect_mt_sms(@dan.phone_number, %{Sorry, I don't understand "3" as an answer to that question. Valid answers are: 1, 2.})

    mo_sms(@dan.phone_number, '123')
    expect_no_mt_sms_including(@dan.phone_number, %{Sorry, I don't understand "123" as an answer to that question. Valid answers are: 1, 2.})
    expect_mt_sms(@dan.phone_number, %{Sorry, I don't understand what "123" means. Text "s" to suggest we add it.})
  end

  context "User responds to question during the window with a bad value, but there's an actual rule with that value" do
    before(:each) do
      Timecop.freeze(@base_time)
      numeric_rule = FactoryGirl.create(:rule, reply: "That's a numeric rule", points: 10, demo: @fooco)
      FactoryGirl.create(:rule_value, value: '200', rule: numeric_rule)
    end

    context "and the user has not yet finished the survey" do
      it "should give an error referring to the existance of the survey" do
        mo_sms(@dan.phone_number, '200')
        expect_no_mt_sms_including(@dan.phone_number, %{Sorry, I don't understand "200" as an answer to that question.})
        expect_mt_sms_including(@dan.phone_number, "That's a numeric rule")
      end
    end

    context "and the user has finished the survey" do
      it "should give an error not referring to the existance of the survey" do
        [@q1, @q2, @q3].each {|question| FactoryGirl.create(:survey_answer, survey_question: question, user: @dan)}

        mo_sms(@dan.phone_number, "200")
        expect_no_mt_sms_including(@dan.phone_number, %{"Sorry, I don't understand "200" as an answer to that question."})
        expect_mt_sms_including(@dan.phone_number, "That's a numeric rule")
      end
    end
  end

  scenario "User responds to question when the survey is not yet open" do
    Timecop.freeze(@survey.open_at - 1.second)
    mo_sms(@dan.phone_number, '1')
    expect_mt_sms @dan.phone_number, %{Sorry, I don't understand what "1" means. Text "s" to suggest we add it.}
  end

  scenario "User responds to question after the survey is closed" do
    Timecop.freeze(@survey.close_at + 1.second)
    mo_sms(@dan.phone_number, '1')
    expect_mt_sms @dan.phone_number, %{Sorry, I don't understand what "1" means. Text "s" to suggest we add it.}
  end

  scenario "User finishes the survey" do
    FactoryGirl.create(:survey_answer, survey_question: @q1, user: @dan)
    FactoryGirl.create(:survey_answer, survey_question: @q2, user: @dan)
    Timecop.freeze(@base_time)

    mo_sms(@dan.phone_number, '4')
    expect_mt_sms(@dan.phone_number, "That was the last question. Thanks for completing the survey!")

    signin_as(@dan, 'foobar')
    expect_content("Dan completed a survey")
  end

  scenario "User tries to send an answer after finishing survey" do
    [@q1, @q2, @q3].each {|question| FactoryGirl.create(:survey_answer, survey_question: question, user: @dan)}
    Timecop.freeze(@base_time)

    mo_sms(@dan.phone_number, '1')
    expect_mt_sms(@dan.phone_number, "Thanks, we've got all of your survey answers already.")
  end

  scenario "User asks for reminder of last question" do
    FactoryGirl.create(:survey_answer, survey_question: @q1, user: @dan)
    FactoryGirl.create(:survey_answer, survey_question: @q2, user: @dan)
    Timecop.freeze(@base_time)

    mo_sms(@dan.phone_number, 'Lastquestion')
    expect_mt_sms(@dan.phone_number, "The last question was: How important is doing what you're told?")
  end
end
