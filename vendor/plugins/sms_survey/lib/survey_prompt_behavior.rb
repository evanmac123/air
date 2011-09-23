module SmsSurvey
  module SurveyPromptBehavior
    extend ActiveSupport::Concern

    included do
      belongs_to :survey

      validates_presence_of :send_time, :text, :survey_id

      after_save :schedule_text_to_users_with_answers_left
    end

    module InstanceMethods
      def text_prompt_to_user(user_id, prompt_id)
        user = User.find(user_id)

        unanswered_questions = SurveyQuestion.unanswered_by(user, self.survey)
        return if unanswered_questions.length == 0

        next_unanswered_question = unanswered_questions.first
        text = [
          self.interpolated_text(unanswered_questions), 
          next_unanswered_question.text
        ].join(' ')

        SMS.send_message(user[self.class.user_phone_column_name], text)
      end

      def interpolated_text(unanswered_questions)
        count = unanswered_questions.length
        remaining_questions = count == 1 ? "question" : "#{count} questions"
        self.text.gsub("%remaining_questions", remaining_questions)
      end
    end

    module ClassMethods
      def user_phone_column_name
        'phone_number'
      end
    end
  end
end
