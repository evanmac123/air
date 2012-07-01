require 'special_command_handlers/base'

class SpecialCommandHandlers::LastQuestionReminderHandler < SpecialCommandHandlers::Base
  def handle_command
    survey = @user.open_survey
    return parsing_error_message("You're not currently taking a survey") unless survey

    question = survey.latest_question_for(@user)
    if question
      parsing_success_message("The last question was: #{question.text}")
    else
      parsing_success_message("You've already answered all of the questions in the survey.")
    end
  end
end
