import React from 'react';
import PropTypes from "prop-types";

import { Fetcher } from "../../../lib/helpers";

const validateEmail = value => {
  const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; // eslint-disable-line
  return re.test(String(value).toLowerCase());
};

const decideIfAnswerIsCorrect = (questionType, correctIndex, index, freeForm) => {
  if (freeForm) {
    return (freeForm.value.length > 0) ? true : 'freeForm';
  } else if (!freeForm && (questionType === 'survey' || correctIndex === -1 || correctIndex === index)) {
    return true;
  }
  return false;
};

const determineIfMarkedCorrect = (tile, key) => (
  (tile.answerIndex === key && tile.complete) ||
  (tile.origin === 'complete' && tile.correctAnswerIndex === key && !tile.complete) ? 'clicked_right_answer' : ''
);

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

const checkAnswerForSubmission = (e, correctIndex, index, tile) => {
  const { id, submitAnswer, complete, questionType, questionSubtype, allowFreeResponse, answers } = tile;
  const { target } = e;
  const freeForm = (questionSubtype === 'free_response' || (allowFreeResponse && index === -1)) ? document.getElementById('free_form_response') : undefined;
  const correctAnswer = decideIfAnswerIsCorrect(questionType, correctIndex, index, freeForm);
  if (complete) { return; }
  target.style.pointerEvents = 'none';
  if (correctAnswer === true) {
    const freeFormAnswer = freeForm ? freeForm.value : null;
    const indexAnswer = freeForm ? (allowFreeResponse ? answers.length : null) : index; // eslint-disable-line
    target.classList.add('clicked_right_answer');
    submitAnswer(id, indexAnswer, freeFormAnswer);
  } else {
    if (correctAnswer === 'freeForm') {
      target.style.pointerEvents = '';
    } else {
      target.classList.add('incorrect', 'clicked_wrong');
    }
    target.nextSibling.classList.add('display-error');
  }
};

const freeResponse = opts => (
  <div className="free-text-panel content_sections" id='free-response-textarea' style={opts.style || {}}>
    {opts.showXBtn &&
      <i className="free-text-hide fa fa-remove fa-1x"
      onClick={e => {
        e.target.parentElement.style.display = "none";
        if (document.getElementById('free-response-button')) {
          document.getElementById('free-response-button').style.display = "block";
        }
      }}
      />
    }
    <textarea
      name="free_form_response"
      id="free_form_response"
      maxLength="400"
      placeholder="Enter your response here"
      className="free-form-response edit with_counter"
      readOnly={(opts.tile.origin === 'complete' || opts.tile.freeFormResponse)}
      onKeyUp={updateCharCount}
      value={opts.tile.origin === 'complete' || opts.tile.freeFormResponse ? (opts.tile.freeFormResponse || '') : undefined}
    />
    <div className="character-counter">400 characters</div>
    <a
      className={`multiple-choice-answer ${opts.tile.origin === 'complete' ? 'clicked_right_answer' : ''}`}
      onClick={opts.submitAction}
    >{opts.submitBtnText || 'Submit'}</a>
    <div className="answer_target">Response cannot be empty</div>
  </div>
);

const formActions = (e, subtype) => {
  const options = e.target.parentElement.parentElement.children;
  for (let i = 0; i < options.length; i++) { options[i].style.display = "none"; }
  document.getElementById(`${subtype}_form_hidden`).style.display = "";
};

const revertSelection = e => {
  const options = e.target.parentElement.parentElement.parentElement.children;
  for (let i = 0; i < options.length; i++) { options[i].style.display = ""; }
  e.target.parentElement.parentElement.style.display = "none";
};

const freeResponseOption = (key, markCorrect) => React.createElement('div', {key, style: {display: 'block'}, id: 'free-response-button'},
  React.createElement('a', {
    className: `multiple-choice-answer ${markCorrect}`,
    onClick: e => {
      const freeResponseTextarea = document.getElementById('free-response-textarea');
      e.target.parentElement.style.display = "none";
      freeResponseTextarea.style.display = "block";
    },
    style: {margin: '0.5em auto'},
  },
  'Other',
));

const renderMultipleChoiceAnswers = (tile, subtype) => {
  const answerCollection = tile.answers.map((answer, key) => React.createElement('div', {key},
    React.createElement(
      'a',
      {
        className: `multiple-choice-answer ${determineIfMarkedCorrect(tile, key)}`,
        onClick: (e) => {
          if (tile.complete || tile.origin === 'complete') { return; } // eslint-disable-line
          if (subtype === 'change_email' || subtype === 'invite_spouse') {
            if (key > 0) {
              checkAnswerForSubmission(e, key, key, tile);
            } else {
              formActions(e, subtype);
            }
          } else {
            checkAnswerForSubmission(e, tile.correctAnswerIndex, key, tile);
          }
        },
        style: {margin: '0.5em auto'},
      },
      answer,
    ),
    React.createElement('div', {className: 'answer_target'}, tile.incorrectText || "Sorry, that's not it. Try again!"),
  ));
  if (tile.allowFreeResponse) {
    const freeResponseMarkedCorrect = determineIfMarkedCorrect(tile, tile.answers.length);
    answerCollection.push(freeResponseOption(tile.id, freeResponseMarkedCorrect));
  }
  return answerCollection;
};

const submitEmailChange = (e, tile) => {
  const email = document.getElementById('change_email_email').value;
  const valid = validateEmail(email);
  const { target } = e;
  target.style.pointerEvents = 'none';
  if (email && valid) {
    Fetcher.xmlHttpRequest({
      method: 'PUT',
      path: '/change_email',
      params: { change_email: { email } },
      success: resp => {
        if (resp.status === 'success') {
          target.innerText = 'Sending validation to new email address';
          target.classList.add('clicked_right_answer');
          setTimeout(() => { tile.submitAnswer(tile.id, 0, null); }, 3000);
        } else {
          document.getElementById('change_email_email').classList.add('error');
          document.getElementById('email_error').innerText = resp.message;
          target.style.pointerEvents = '';
        }
      },
    });
  } else {
    document.getElementById('change_email_email').classList.add('error');
    document.getElementById('email_error').innerText = "A valid email address is required";
  }
};

const submitSpouseInvitation = (e, tile) => {
  const email = document.getElementById('dependent_user_invitation_email').value;
  const subject = document.getElementById('dependent_user_invitation_subject').value;
  const body = document.getElementById('dependent_user_invitation_body').value;
  const valid = validateEmail(email);
  if (email && subject && body && valid) {
    const { target } = e;
    target.style.pointerEvents = 'none';
    Fetcher.xmlHttpRequest({
      method: 'POST',
      path: '/invitation/dependent_user_invitation',
      params: { dependent_user_invitation: {email, subject, body, json: true} },
      success: resp => {
        if (resp.status === 'success') {
          target.innerText = 'Sending invitation';
          target.classList.add('clicked_right_answer');
          setTimeout(() => { tile.submitAnswer(tile.id, 0, null); }, 3000);
        } else {
          document.getElementById('spouse_form_error').innerText = "Something went wrong. Please try again later.";
          target.style.pointerEvents = '';
        }
      },
    });
  } else {
    const error = valid ? "All fields must be filled" : "A valid email address is required";
    document.getElementById('spouse_form_error').innerText = error;
  }
};

const multipleChoice = (tile, subtype) => (
  <div className="multiple_choice_group content_sections">
    {renderMultipleChoiceAnswers(tile, subtype)}
    {(subtype === 'change_email') &&
      <div id="change_email_form_hidden" style={{display: 'none'}}>
        <label>New Email Address</label>
        <input type="text" name="change_email[email]" id="change_email_email" placeholder="example@email.com" />
        <label className="change_email_error err" id="email_error"></label>
        <a className="tile_button multiple-choice-answer" onClick={e => { submitEmailChange(e, tile); }}>Change email</a>
        <p>
          <a className="no_email_change righty" onClick={revertSelection}>Nevermind, I don’t want to change my email.</a>
        </p>
      </div>
    }
    {(subtype === 'invite_spouse') &&
      <div id="invite_spouse_form_hidden" style={{display: 'none'}}>
          <label>To</label>
          <input type="text" name="dependent_user_invitation[email]" id="dependent_user_invitation_email" placeholder="example@email.com" />

          <label>Subject</label>
          <input type="text" name="dependent_user_invitation[subject]" id="dependent_user_invitation_subject" defaultValue={tile.dependentBoardSubject} />

          <label>Body</label>
          <textarea name="dependent_user_invitation[body]" id="dependent_user_invitation_body" rows="4" defaultValue={tile.dependentBoardBody}></textarea>

          <label className="change_email_error err" id="spouse_form_error"></label>
          <a className="tile_button multiple-choice-answer" onClick={e => { submitSpouseInvitation(e, tile); }}>Send</a>
          <p>
            <a className="no_invitation righty" onClick={revertSelection}>Nevermind, I don’t want to send an invitation.</a>
          </p>
      </div>
    }
    {tile.allowFreeResponse ? freeResponse({
        tile,
        submitAction: e => { checkAnswerForSubmission(e, tile.correctAnswerIndex, -1, tile); },
        showXBtn: !tile.freeFormResponse,
        style: {display: tile.freeFormResponse ? 'block' : 'none'},
      }) : ''
    }
  </div>
);

const tileQuiz = tile => {
  switch (tile.questionSubtype) {
    case 'free_response':
      return freeResponse({
        tile,
        submitBtnText: tile.answers[0],
        submitAction: (e) => { checkAnswerForSubmission(e, tile.correctAnswerIndex, 0, tile); },
      });
    case 'true_false':
    case 'multiple_choice':
    case 'rsvp_to_event':
      return multipleChoice(tile);
    case 'change_email':
    case 'invite_spouse':
      return multipleChoice(tile, tile.questionSubtype);
    default:
      return (
        <div className="multiple_choice_group content_sections">
          <div>
            <a className={`multiple-choice-answer ${determineIfMarkedCorrect(tile, 0)}`} onClick={(e) => { checkAnswerForSubmission(e, 0, 0, tile); }}>{tile.answers[0]}</a>
          </div>
        </div>
      );
  }
};

const TileQuizComponent = props => (
  <div id="tile-quiz-section" className="tile_quiz" style={{pointerEvents: props.tile.complete || props.tileOrigin === 'complete' ? 'none' : ''}}>
    {tilePointsBar(props.tile.points, props.organization.pointsWording)}
    <div className="tile_question content_sections">{props.tile.question}</div>
    {tileQuiz({...props.tile, submitAnswer: props.submitAnswer, origin: props.tileOrigin})}
  </div>
);

TileQuizComponent.propTypes = {
  tile: PropTypes.shape({
    points: PropTypes.number,
    pointLabel: PropTypes.string,
    question: PropTypes.string,
    complete: PropTypes.bool,
  }),
  organization: PropTypes.object,
  tileOrigin: PropTypes.string,
  submitAnswer: PropTypes.func,
};

export default TileQuizComponent;
