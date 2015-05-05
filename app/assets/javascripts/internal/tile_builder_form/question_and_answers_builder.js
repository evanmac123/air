window.questionAndAnswersBuilder = function(tileHasQuestionType, defaultType, defaultSubtype){
  setUp(tileHasQuestionType, defaultType, defaultSubtype);
  //
  //  => Events
  //
  $(".subtype").click(function selectSubtype(){
    type = getTileType($(this).attr("id"));
    subtype = getTileSubtype($(this).attr("id"));

    makeButtonsSelected(type, $(this).attr("id"));
    showQuestionAndAnswers(tileTypes[type][subtype]);
    showSelectAndAddAnswer();
    saveTypeToForm();

    _.each($('.answer-field'), addCharacterCounterFor);
    turnRadioGreen();
    selectMessage();
    rebindEvents();
    //show slider
    $(".slider").css("display", "block");
  });

  $('body').click(function(event) {
    if (!$(event.target).is(".tile_question") && !$(event.target).is("#tile_builder_form_question")) {
      turnOffEditQuestion();
    }
    if(!$(event.target).attr("data-dropdown")){
      $(".f-dropdown").each(function() {
        $(this).removeClass("open").removeAttr("style");
      });
    }
    tryTurnOffEditAnswer(event.target);
  });

  $(".type").click(function closeOtherDropdowns() {
    list_id = $(this).attr("data-dropdown");
    $(".f-dropdown").each(function() {
      if(list_id != $(this).attr("id")){
        $(this).removeClass("open").removeAttr("style");
      }
    });
  });

  function rebindEvents() {
    $("#tile_builder_form_question").bind('input propertychange', function() {
      saveQuestionChanges(this);
    });

    $(".answer-field.answer-part").bind('input propertychange', function() {
      saveAnswerChanges(this);
    });

    $(".tile_question").click(function() {
      turnOnEditQuestion(this);
    });

    $(".tile_multiple_choice_answer a").click(function() {
      turnOnEditAnswer(this);
    });

    var initialAnswerField = $('.answer_option').eq(0);

    $('.add_answer').click(function(e) {
      addNewAnswer();
    });

    $('.answer-field').keydown(function openNextAnswerOnTab(e) {
      code = e.keyCode || e.which;
      next_answer = $(this).closest(".tile_multiple_choice_answer").next(".tile_multiple_choice_answer");
      if (code == '9') {
        if(next_answer.length > 0){
          next_answer.find("a").click();
          return false;
        }else{
          turnOffEditAnswer($(this).closest(".tile_multiple_choice_answer"));
        }
      }
    });

    $('#tile_builder_form_question').keydown(function openFirstAnswerOnTab(e) {
      code = e.keyCode || e.which;
      if (code == '9') {
        $(".multiple_choice_group").find(".tile_multiple_choice_answer").first().find("a:first").click();
        return false;
      }
    });
  };

  function turnRadioGreen() {
    $('.option_radio').unbind();
    $('.option_radio').click(function() {
      var radioButton = $(this).find('input:radio');
      if($(this).hasClass('option_selected')){
        $('.option_radio').removeClass('option_selected');  
        radioButton.prop('checked', false);
      }else {
        $('.option_radio').removeClass('option_selected');  
        radioButton.attr('checked','true');
        $(this).addClass('option_selected');
      } 
      markRightAnswer(this);
    });
  };
  //
  //  => Functions
  //
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

  function showAnswerContainer(display, text, correct) {
    container = buildContainer(display, text, '<a></a>');
    if(correct){
      container.addClass("clicked_right_answer");
    }
    return container;
  };

  function editAnswerContainer(display, text, index, correct) {
    type = $(".selected.button").attr("id");
    edit_answer_container = $('<ul class="answer_option"></ul>');
    option_radio = $(
      ['<li class="option_radio">',
          '<input class="correct-answer-button answer-part" id="tile_builder_form_correct_answer_index_' + index,
          '" name="tile_builder_form[correct_answer_index]" type="radio" value="' + index, '">',
        '</li>'].join(''));
    option_input = $(
      ['<li class="option_input">',
          '<div class="answer-div">',
            '<input class="answer-field answer-part" data="' + index,
            '" maxlength="50" name="tile_builder_form[answers][]" type="text">',
          '</div>',
        '</li>'].join(''));
    if(type == "Quiz") {
      edit_answer_container.append(option_radio);
    };
    edit_answer_container.append(option_input);
    text_input = edit_answer_container.find(".answer-field.answer-part");
    text_input.val(text);
    edit_answer_container.css("display", display);
    if(correct){
      edit_answer_container.find(".option_radio").addClass("option_selected");
      edit_answer_container.find(".correct-answer-button.answer-part").attr("checked", true);
    }
    return edit_answer_container;
  };

  function addNewAnswer(){
    type_name = findTileType();
    subtype_name = findTileSubtype();

    answer_text = "Add Answer Option";
    subtype = tileTypes[type_name][subtype_name];
    if(subtype["answers"]){
      i = subtype["answers"].length
    }else{
      tileTypes[type_name][subtype_name]["answers"] = [];
      i = 0
    }
    tileTypes[type_name][subtype_name]["answers"][i] = answer_text; 

    $("li.selected").click();
    $("li.selected").click();
  }

  function addAnswers(container, answers, correct_index) {
    type = findTileType();
    subtype = findTileSubtype();

    answers_group = $('<div class="multiple_choice_group"></div>');
    container.append(answers_group);
    for(i in answers) {

      if(correct_index == i){
        correct = true;
      }else{
        correct = false;
      }

      answer = $('<div class="tile_multiple_choice_answer"></div>');
      answers_group.append(answer); 
      answer.append(showAnswerContainer("block", answers[i], correct));
      answer.append(editAnswerContainer("none", answers[i], i, correct));
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
    return buildContainer(display, text, '<div class="tile_question"></div>');
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
    addAnswers(quiz_content, subtype["answers"], subtype["correct"]);
  };

  function addAnswerSelectedMessage(container) {
    answer_container = $('<div class="choose_answer columns small-8"></div>');
    container.append(answer_container);
  }

  function showAddAnswer(container) {
    add_container = $('<div class="add_answer columns"></div>');
    icon = $('<i class="fa fa-plus"></i>');
    meassage = "  Add another answer";
    add_container.text(meassage).prepend(icon);
    container.append(add_container);
  }

  function showSelectAndAddAnswer() {
    after_answers = $('<div class="after_answers row"></div>');
    if(type == "Quiz"){
      addAnswerSelectedMessage(after_answers);
    }else{
      after_answers.append('<div class="columns"></div>');
    }
    if(subtype == "multiple_choice" && (type == "Quiz" || type == "Survey")){
      showAddAnswer(after_answers);
    }
    $(".quiz_content").append(after_answers);
  }

  function selectMessage() {
    select_message = $(".choose_answer");
    if($(".option_selected").length > 0) {
      select_message.removeClass("no_answer").addClass("have_answer");
      icon = $('<i class="fa fa-check"></i>');
      meassage = "  Correct answer selected";
    }else {
      select_message.removeClass("have_answer").addClass("no_answer");
      icon = $('<i class="fa fa-info-circle"></i>');
      meassage = "  Correct answer not selected";
    }
    select_message.text(meassage).prepend(icon);
  }

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

    tileTypes[type][subtype]["question"] = $(question_filed).val();
    $(".tile_question").html(tileTypes[type][subtype]["question"]);
  };

  function getAnswerIndex(answer_input){
    return $(answer_input).attr("data");
  }

  function updateShowAnswer(text, answer_input){
    $(answer_input).closest(".tile_multiple_choice_answer").find("a").html(text);
  }

  function saveAnswerChanges(answer_input) {
    type = findTileType();
    subtype = findTileSubtype();
    answer_index = getAnswerIndex(answer_input);
    tileTypes[type][subtype]["answers"][answer_index] = $(answer_input).val();
    updateShowAnswer(tileTypes[type][subtype]["answers"][answer_index], answer_input);
  };

  function highlightText(input) {
    input.focus();
    input.select();
  }

  function turnOnEditQuestion(question_show) {
    question_edit = $(question_show).parent().find("#tile_builder_form_question");
    question_edit.css("display", "block");
    highlightText(question_edit);
    $(question_show).css("display", "none");
  }

  function turnOnEditAnswer(answer_show) {
    $(answer_show).parent().find(".answer_option").css("display", "block");
    highlightText($(answer_show).parent().find(".answer-field"));
    $(answer_show).css("display", "none");
  }

  function turnOffEditQuestion() {
    $(".tile_question").css("display", "block");
    $("#tile_builder_form_question").css("display", "none");
  }

  function turnOffEditAnswer(answer_div) {
    $(answer_div).find("a").css("display", "block");
    $(answer_div).find(".answer_option").css("display", "none");
  }

  function tryTurnOffEditAnswer(element) {
    $(".tile_multiple_choice_answer").each(function() {
      if( !$(this).is( $(element).closest(".tile_multiple_choice_answer") ) ) {
        turnOffEditAnswer(this);
      };
    });
  }

  function makeAnswerGreen(radio) {
    answer_show = $(radio).closest(".tile_multiple_choice_answer").find("a");
    if(!$(answer_show).is($(".clicked_right_answer"))){
      $(".clicked_right_answer").removeClass("clicked_right_answer");
    }
    answer_show.toggleClass("clicked_right_answer");
  }

  function markRightAnswer(element) {
    makeAnswerGreen(element); 
    selectMessage();
    saveRightAnswer(element);
  }

  function saveRightAnswer(element) {
    type = findTileType();
    subtype = findTileSubtype();

    if($(element).hasClass("option_selected")){
      correct = $(element).find("input").val();
    }else {
      correct = -1;
    }
    tileTypes[type][subtype]["correct"] = correct;
  } 

  function saveTypeToForm() {
    type = findTileType();
    subtype = findTileSubtype();

    $("#tile_builder_form_question_type").val(type);
    $("#tile_builder_form_question_subtype").val(subtype); 
  }

  function initialTypeSetUp(tileHasQuestionType, defaultType, defaultSubtype){
    if(tileHasQuestionType == true){
      $("#" + defaultType + "-" + defaultSubtype).click().click();
      $(".slider").css("display", "block");
    }
  }

  function setUp(tileHasQuestionType, defaultType, defaultSubtype) {
    $().ready(function(){
      _.each($('.answer-field'), addCharacterCounterFor);
      turnRadioGreen();
      initialTypeSetUp(tileHasQuestionType, defaultType, defaultSubtype);
    });
  }
}
