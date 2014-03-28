function getTileType(str){
  return str.match(/(.*)-/)[1];
};

function getTileSubtype(str){
  return str.match(/-(.*)/)[1];
};

function findTileType() {
  return getTileType($("li.selected").attr("id"));
};

function findTileSubtype() {
  return getTileSubtype($("li.selected").attr("id"));
};

function showAnswerContainer(display, text) {
  return buildContainer(display, text, '<a></a>');
};

function editAnswerContainer(display, text, index) {
  edit_answer_container = $(
    [ '<ul class="answer_option">',
        '<li class="option_radio">',
          '<input class="correct-answer-button answer-part" id="tile_builder_form_correct_answer_index_"' + index,
          ' name="tile_builder_form[correct_answer_index]" type="radio" value="0">',
        '</li>', 
        '<li class="option_input">',
          '<input class="answer-field answer-part" id="tile_builder_form_answers_" maxlength="50" name="tile_builder_form[answers][]" type="text" value="sedfg">',
        '</li>',
      '</ul>'].join(''));
  text_input = edit_answer_container.find(".answer-field.answer-part");
  text_input.val(text);
  edit_answer_container.css("display", display);
  return edit_answer_container;
};

function addAnswers(container, answers) {
  answers_group = $('<div class="multiple_choice_group"></div>');
  container.append(answers_group);
  for(i in answers) {
    answer = $('<div class="tile_multiple_choice_answer"></div>');
    answers_group.append(answer); 
    answer.append(showAnswerContainer("block", answers[i]));
    answer.append(editAnswerContainer("none", answers[i], i));
  }
};

function buildContainer(display, text, html) {
  container = $(html); 
  container.html(text);
  if(display.length > 0 ){
    container.css("display", display);
  }
  return container;
};

function showQuestionContainer(display, text) {
  return buildContainer(display, text, '<div class="tile_question has-tip" data-tooltip title="Click to edit"></div>');
};

function editQuestionContainer(display, text) {
  return buildContainer(display, text, '<textarea cols="40" id="tile_builder_form_question" name="tile_builder_form[question]" rows="20"></textarea>');
};

function addQuestion(container, question) {
  quiz_question = $('<div id="quiz_question"></div>');
  container.append(quiz_question);
  quiz_question.append(showQuestionContainer("block", question));
  quiz_question.append(editQuestionContainer("none", question));
};

function showQuestionAndAnswers(subtype) {
  $(".quiz_content").html("");
  quiz_content = $(".quiz_content");
  addQuestion(quiz_content, subtype["question"]);
  addAnswers(quiz_content, subtype["answers"]);
};

function makeButtonsSelected(type, subtype) {
  $("#" + type).click();

  $(".button.selected").removeClass("selected");
  $(".subtype.selected").removeClass("selected");

  $("#" + type).addClass("selected");
  $("#" + subtype).addClass("selected");
};

function saveQuestionChanges(question_filed) {
  type = findTileType();
  subtype = findTileSubtype();

  tile_types[type][subtype]["question"] = $(question_filed).val();
  $(".tile_question").html(tile_types[type][subtype]["question"]);
};

function getAnswerIndex(answer_input){
  return $(answer_input).parent().parent().find(".correct-answer-button").val();
}

function updateShowAnswer(text, answer_input){
  $(answer_input).parent().parent().parent().find("a").html(text);
}

function saveAnswerChanges(answer_input) {
  type = findTileType();
  subtype = findTileSubtype();
  answer_index = getAnswerIndex(answer_input);
  tile_types[type][subtype]["answers"][answer_index] = $(answer_input).val();
  updateShowAnswer(tile_types[type][subtype]["answers"][answer_index], answer_input);
};

function turnOnEditQuestion(question_show) {
  $(question_show).parent().find("#tile_builder_form_question").css("display", "block");
  $(question_show).css("display", "none");
}

function turnOnEditAnswer(answer_show) {
  $(answer_show).parent().find(".answer_option").css("display", "block");
  $(answer_show).css("display", "none");
}