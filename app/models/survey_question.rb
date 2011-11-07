class SurveyQuestion < ActiveRecord::Base
  include SmsSurvey::SurveyQuestionBehavior

  protected

  def alternative_handling_possible?(choice)
    survey.demo.has_rule_value_matching?(choice) 
  end

  def after_question_hook(user)
    act_text = if user.demo.survey_answer_activity_message.present?
                 user.demo.survey_answer_activity_message
               else
                 "answered a survey question"
               end

    user.acts.create(:inherent_points => self.points, :text => act_text)
  end

  def after_final_question_hook(user)
    user.acts.create(:text => 'completed a survey')
  end

  def question_acknowledgement_phrase(next_question)
    next_question ? next_question.text : "That was the last question. Thanks for completing the survey!"
  end
end
