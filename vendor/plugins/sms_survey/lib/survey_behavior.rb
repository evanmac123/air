module SmsSurvey
  module SurveyBehavior
    extend ActiveSupport::Concern

    included do
      belongs_to :demo
      has_many :survey_questions
      has_many :survey_valid_answers, :through => :survey_questions
      has_many :survey_prompts

      validates_presence_of :name, :open_at, :close_at

      validate :close_comes_after_open
    end


    module InstanceMethods
      def close_comes_after_open
        return unless open_at && close_at

        errors.add(:base, "Close time must be after open time") unless close_at > open_at
      end

      def latest_question_for(user)
        SurveyQuestion.unanswered_by(user, self).first
      end
    end

    module ClassMethods
      def open
        time = Time.now
        self.where(['? BETWEEN open_at AND close_at', Time.now])
      end
    end


  end
end
