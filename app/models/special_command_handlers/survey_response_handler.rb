require 'special_command_handlers/base'

class SpecialCommandHandlers::SurveyResponseHandler < SpecialCommandHandlers::Base
  def handle_command
    survey = @user.open_survey
    return nil unless survey

    choice = @command_name

    question = survey.latest_question_for(@user)

    if question
      question.respond(@user, survey, choice)
    else
      return nil if survey.demo.has_rule_value_matching?(choice) # Give Act.parse a crack at it
      parsing_success_message(survey.all_answers_already_message)
    end
  end
end
