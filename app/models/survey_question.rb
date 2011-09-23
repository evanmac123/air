class SurveyQuestion < ActiveRecord::Base
  include SmsSurvey::SurveyQuestionBehavior

  protected

  def alternative_handling_possible?(choice)
    survey.demo.has_rule_value_matching?(choice) 
  end

  def after_question_hook(user)
    user.acts.create(:inherent_points => self.points, :text => "answered a health personality question")
  end

  def after_final_question_hook(user)
    user.acts.create(:text => 'completed a health personality survey')
  end

  def question_acknowledgement_phrase(next_question)
    "Got it! #{points_phrase}#{next_question_phrase(next_question)}"
  end

  def points_phrase
    self.points ? 
      "(And you get #{self.points} points.) " :
      ''
  end
end
