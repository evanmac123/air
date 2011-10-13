class Survey < ActiveRecord::Base
  include SmsSurvey::SurveyBehavior

  belongs_to :demo

  def all_answers_already_message
    "Thanks, we've got all of your survey answers already."      
  end
end
