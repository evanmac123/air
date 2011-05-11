class SurveyPrompt < ActiveRecord::Base
  belongs_to :survey
  has_one :demo, :through => :survey

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
    self.demo.users.ranked.each do |user|
      delay.text_prompt_to_user(user.id, self.id)
    end
  end

  def text_prompt_to_user(user_id, prompt_id)
    user = User.find(user_id)

    unanswered_questions = self.survey.survey_questions.unanswered_by(user)
    return if unanswered_questions.length == 0

    next_unanswered_question = unanswered_questions.first
    text = [
      self.interpolated_text(unanswered_questions), 
      next_unanswered_question.text
    ].join(' ')

    SMS.send(user.phone_number, text)
  end

  def interpolated_text(unanswered_questions)
    count = unanswered_questions.length
    remaining_questions = count == 1 ? "question" : "#{count} questions"
    self.text.gsub("%remaining_questions", remaining_questions)
  end
end
