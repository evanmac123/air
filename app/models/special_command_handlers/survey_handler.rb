require 'special_command_handlers/base'

class SpecialCommandHandlers::SurveyHandler < SpecialCommandHandlers::Base
  def handle_command
    survey = Survey.open.where(:demo_id => @user.demo_id).first

    unless survey.present?
      return parsing_error_message("Sorry, there is not currently a survey open.")
    end

    question = survey.latest_question_for(@user)
    if question
      parsing_success_message(survey.latest_question_for(@user).text)
    else
      parsing_success_message(survey.all_answers_already_message)
    end
  end
end
