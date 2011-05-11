class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_valid_answers

  validates_presence_of :text
  validates_presence_of :survey_id
  validates_uniqueness_of :index, :scope => :survey_id

  def respond(user, survey, choice)
    valid_answer = self.survey_valid_answers.where(:value => choice).first
    return bad_answer_error(choice) unless valid_answer

    SurveyAnswer.create(:user => user, :survey_question => self, :survey_valid_answer => valid_answer)
    user.acts.create(:inherent_points => self.points, :text => "answered a health personality question")

    points_phrase = self.points ? 
                      "(And you get #{self.points} points.) " :
                      ''

    next_question = self.class.questions_after(self.index).first
    next_question_phrase = next_question ?
                             "Next question: #{next_question.text}" :
                             "That was the last question. Thanks for completing the survey!"

    unless next_question
      user.acts.create(:text => 'completed a health personality survey')
    end

    "Got it! #{points_phrase}#{next_question_phrase}"
  end

  def self.unanswered_by(user)
    last_answer = user.survey_answers.
                    joins('INNER JOIN survey_questions ON survey_answers.survey_question_id = survey_questions.id').
                    order('survey_questions.index DESC').
                    limit(1).
                    includes(:survey_question).
                    first
    
    last_answer_index = if last_answer
                          last_answer.survey_question.index
                        else
                          -1
                        end

    questions_after(last_answer_index)
  end

  def self.questions_after(index)
    self.where(['index > ?', index]).order('index ASC')
  end

  protected

  def bad_answer_error(choice)
    valid_answer_phrase = self.survey_valid_answers.map(&:value).sort.join(', ')
    "Sorry, I don't understand \"#{choice}\" as an answer to that question. Valid answers are: #{valid_answer_phrase}."
  end
end
