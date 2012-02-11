class SurveyPrompt < ActiveRecord::Base
  has_one :demo, :through => :survey
  belongs_to :survey

  validates_presence_of :send_time, :text, :survey_id

  after_save :schedule_text_to_users_with_answers_left

  protected

  # We split up bulk SMS sending into many jobs like this for two reasons:
  #
  # (1) This reduces coupling between individual message sends, so if one
  # fails, others won't be affected, without us having to dick around writing
  # exception-handling code: DJ will do most of what we would want to.
  #
  # (2) This slows down the rate that messages go out through Twilio, which,
  # given their one-outgoing-message-per-second throttle, is a Good Thing. It
  # means other outgoing messages (action replies, etc.) have a chance to get
  # out in between prompt messages.

  def schedule_text_to_users_with_answers_left
    self.delay(:run_at => self.send_time).text_to_users_with_answers_left
  end

  def text_to_users_with_answers_left
    self.demo.users.claimed.each do |user|
      delay.text_prompt_to_user(user.id, self.id)
    end
  end

  def text_prompt_to_user(user_id, prompt_id, mode=:outbound)
    user = User.find(user_id)

    unanswered_questions = SurveyQuestion.unanswered_by(user, self.survey)
    return if unanswered_questions.length == 0

    next_unanswered_question = unanswered_questions.first
    text = [
      self.interpolated_text(unanswered_questions), 
      next_unanswered_question.text
    ].join(' ')

    case mode
    when :outbound
      OutgoingMessage.send_message(user, text)
    when :reply
      text
    end
  end

  def interpolated_text(unanswered_questions)
    count = unanswered_questions.length
    remaining_questions = count == 1 ? "question" : "#{count} questions"
    self.text.gsub("%remaining_questions", remaining_questions)
  end
end
