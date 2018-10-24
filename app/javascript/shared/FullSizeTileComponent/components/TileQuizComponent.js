import React from 'react';
import PropTypes from "prop-types";

const decideIfAnswerIsCorrect = (correctIndex, index, freeForm) => {
  if (freeForm) {
    return (freeForm.value.length > 0) ? true : 'freeForm';
  } else if (!freeForm && (correctIndex === -1 || correctIndex === index)) {
    return true;
  }
  return false;
};

const tilePointsBar = (points, pointLabel) => (
  <div className="tile_points_bar">
    <div className="earnable_points">
      <span className="num_of_points" id="tile_point_value">{points}</span>
      <span className="points_label">{pointLabel || 'points'}</span>
    </div>
  </div>
);

const updateCharCount = e => {
  const charsLeft = 400 - e.target.value.length;
  e.target.nextElementSibling.innerText = `${charsLeft} CHARACTERS`;
};

const submitAnswer = (e, correctIndex, index, nextTile) => {
  const { target } = e;
  const freeForm = document.getElementById('free_form_response');
  const correctAnswer = decideIfAnswerIsCorrect(correctIndex, index, freeForm);
  target.style.pointerEvents = 'none';
  if (correctAnswer === true) {
    target.classList.add('clicked_right_answer');
    window.setTimeout(nextTile, 250);
  } else {
    if (correctAnswer === 'freeForm') {
      target.style.pointerEvents = '';
    } else {
      target.classList.add('incorrect', 'clicked_wrong');
    }
    target.nextSibling.classList.add('display-error');
  }
};

const freeResponse = tile => (
  <div className="free-text-panel content_sections">
    <textarea name="free_form_response" id="free_form_response" maxLength="400" placeholder="Enter your response here" className="free-form-response edit with_counter" onKeyUp={updateCharCount}></textarea>
    <div className="character-counter">400 characters</div>
    <a className="multiple-choice-answer" onClick={(e) => { submitAnswer(e, tile.correctAnswerIndex, 0, tile.getNextTile); } }>{tile.answers[0]}</a>
    <div className="answer_target">Response cannot be empty</div>
  </div>
);

const multipleChoice = (tile, subtype) => (
  <div className="multiple_choice_group content_sections">
    {tile.answers.map((answer, key) => React.createElement('div', {key},
      React.createElement(
        'a',
        { className: "multiple-choice-answer", onClick: (e) => { submitAnswer(e, tile.correctAnswerIndex, key, tile.getNextTile); }, style: {margin: '0.5em auto'} },
        answer,
      ),
      React.createElement('div', {className: 'answer_target'}, tile.incorrectText || "Sorry, that's not it. Try again!"),
    ))}
  </div>
);

const tileQuiz = tile => {
  switch (tile.questionSubtype) {
    case 'free_response':
      return freeResponse(tile);
    case 'true_false':
    case 'multiple_choice':
      return multipleChoice(tile);
    case 'rsvp_to_event':
    case 'change_email':
      return multipleChoice(tile, tile.questionSubtype);
    default:
      return (
        <div className="multiple_choice_group content_sections">
          <div>
            <a className="multiple-choice-answer correct" onClick={(e) => { submitAnswer(e, 0, 0, tile.getNextTile); }}>{tile.answers[0]}</a>
          </div>
        </div>
      );
  }
};

const TileQuizComponent = props => (
  <div className="tile_quiz">
    {tilePointsBar(props.tile.points, props.tile.pointLabel)}
    <div className="tile_question content_sections">{props.tile.question}</div>
    {tileQuiz({...props.tile, getNextTile: props.nextTile})}
  </div>
);

TileQuizComponent.propTypes = {
  tile: PropTypes.shape({
    points: PropTypes.number,
    pointLabel: PropTypes.string,
    question: PropTypes.string,
  }),
  nextTile: PropTypes.func,
};

export default TileQuizComponent;
