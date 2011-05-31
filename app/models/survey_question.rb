class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_valid_answers

  validates_presence_of :text
  validates_presence_of :survey_id
  validates_presence_of :index
  validates_uniqueness_of :index, :scope => :survey_id

  def respond(user, survey, choice)
    valid_answer = self.survey_valid_answers.where(:value => choice).first
    unless valid_answer
      # If a rule with the chosen value exists, punt on answering questions
      # so we can parse it normally.
      if survey.demo.has_rule_value_matching?(choice)
        return nil
      else
        return bad_answer_error(choice) unless valid_answer
      end
    end

    record_answer(user, valid_answer)

    next_question = survey.latest_question_for(user)
    unless next_question
      user.acts.create(:text => 'completed a health personality survey')
    end

    "Got it! #{points_phrase}#{next_question_phrase(next_question)}"
  end

  def self.unanswered_by(user, survey)
    last_answer = user.survey_answers.
                    joins('INNER JOIN survey_questions ON survey_answers.survey_question_id = survey_questions.id').
                    where(['survey_questions.survey_id = ?', survey.id]).
                    order('survey_questions.index DESC').
                    limit(1).
                    first
    
    last_answer_index = if last_answer
                          last_answer.survey_question.index
                        else
                          -1
                        end

    survey.survey_questions.after_index(last_answer_index)
  end

  def self.after_index(index)
    self.where(['index > ?', index]).order('index ASC')
  end

  protected

  def bad_answer_error(choice)
    valid_answer_phrase = self.survey_valid_answers.map(&:value).sort.join(', ')
    "Sorry, I don't understand \"#{choice}\" as an answer to that question. Valid answers are: #{valid_answer_phrase}."
  end

  def record_answer(user, valid_answer)
    SurveyAnswer.create(:user => user, :survey_question => self, :survey_valid_answer => valid_answer)
    user.acts.create(:inherent_points => self.points, :text => "answered a health personality question")
  end

  def points_phrase
    self.points ? 
      "(And you get #{self.points} points.) " :
      ''
  end

  def next_question_phrase(next_question)
    next_question ?
      "Next question: #{next_question.text}" :
      "That was the last question. Thanks for completing the survey!"
  end
end
