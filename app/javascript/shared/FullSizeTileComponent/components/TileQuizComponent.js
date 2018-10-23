import React from 'react';
import PropTypes from "prop-types";

const tilePointsBar = (points, pointLabel) => (
  <div className="tile_points_bar">
    <div className="earnable_points">
      <span className="num_of_points" id="tile_point_value">{points}</span>
      <span className="points_label">{pointLabel || 'points'}</span>
    </div>
  </div>
);

const freeResponse = tile => (
  <div className="free-text-panel content_sections">
    <textarea name="free_form_response" id="free_form_response" maxLength="400" placeholder="Enter your response here" className="free-form-response edit with_counter"></textarea>
    <div className="character-counter">400 characters</div>
    <a className="multiple-choice-answer correct">{tile.answers[0]}</a>
    <div className="answer_target" style={{display: "none"}}>Response cannot be empty</div>
  </div>
);

const multipleChoice = (tile, subtype) => (
  <div className="multiple_choice_group content_sections">
    <div>
      {tile.answers.map((answer, key) => React.createElement(
        'a',
        { key, className: "multiple-choice-answer", onClick: () => {console.log(key, tile.correctAnswerIndex)} },
        answer,
      ))}
    </div>
  </div>
);

const tileQuiz = tile => {
  switch (tile.questionSubtype) {
    case 'free_response':
      return freeResponse(tile);
      break;
    case 'true_false':
    case 'multiple_choice':
      return multipleChoice(tile);
      break;
    case 'rsvp_to_event':
    case 'change_email':
      return multipleChoice(tile, tile.questionSubtype);
      break;
    default:
      return (
        <div className="multiple_choice_group content_sections">
          <div>
            <a className="multiple-choice-answer correct" onClick={() => console.log('ANSWER!')}>{tile.answers[0]}</a>
          </div>
        </div>
      );
  }
};

const TileQuizComponent = props => (
  <div className="tile_quiz">
    {tilePointsBar(props.tile.points, props.tile.pointLabel)}
    <div className="tile_question content_sections">{props.tile.question}</div>
    {tileQuiz({...props.tile})}

  </div>
);

export default TileQuizComponent;
