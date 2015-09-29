var Airbo = window.Airbo || {};
//FIXME this entire module is shit and needs to be Completely rewritten !!!!!!!!!!! 

Airbo.TileQuestionBuilder = (function(){
  var tileTypes = []
    , tileHasQuestionType
    , tileTextContainer
    , defaultType
    , defaultSubtype
    , tilebuilderform
    , multipleChoiceAnswerSelector = ".tile_multiple_choice_answer"
    , delAnswerSelector = ".fa.fa-remove"
    , tileTextContainerSelector = "#new_tile_builder_form .tile_texts_container"
    , typeSelector = ".type"
    , subtypeSelector = ".subtype"
    , sliderSelector = ".slider"
    , dropdownSelector = ".f-dropdown"
    , answerFieldSelector = ".answer-field"
    , tileBuilderFormSelector = "#new_tile_builder_form"
    , tileTextContainerSelector = "#new_tile_builder_form .tile_texts_container"
  ;

  function initSubType() {

    $("body").on("click", subtypeSelector, function(){
      var obj = {}
      obj.subtypeId = $(this).attr("id");
      obj.type = getTileType(obj.subtypeId);
      obj.subtype = getTileSubtype(obj.subtypeId);

      addSubTypeAnswer(obj)

      saveTypeToForm();
      _.each($(answerFieldSelector), addCharacterCounterFor);

      $(".tile_quiz").removeClass("tile_builder_error");
      turnRadioGreen();
      rebindEvents();
      showSlider();

    });
  }


  function addSubTypeAnswer(obj){
    makeButtonsSelected(obj.type, obj.subtypeId);
    showQuestionAndAnswers(tileTypes[obj.type][obj.subtype]);
    showSelectAndAddAnswer(obj.type, obj.subtype);
  }

  function addNewAnswer(){
    var answer_text = "Add Answer Option";
    var type_name = findTileType();
    var subtype_name = findTileSubtype();
    var subtype = tileTypes[type_name][subtype_name];
    var i =0;
    if(subtype["answers"]){
      i = subtype["answers"].length
    }else{
      tileTypes[type_name][subtype_name]["answers"] = [];
    }

    tileTypes[type_name][subtype_name]["answers"][i] = answer_text; 

    addIndividualAnswer(subtype)

    rebindEvents();
  }


  function addAnswers(container, answers, correct_index) {
    var type = findTileType();
    var subtype = findTileSubtype();

    var answers_group = $('<div class="multiple_choice_group"></div>').addClass(type.toLowerCase());
    container.append(answers_group);
    
    for(i in answers) {

      if(correct_index == i){
        correct = true;
      }else{
        correct = false;
      }
      addAnswerToGroup(answers, correct,subtype, i);
    }
  };

  function addIndividualAnswer(subtype){
    addAnswerToGroup(["Add Answer Option"], false, subtype, 0)
  }

  function addAnswerToGroup(answerList, correct,subtype, i){
    answer = $('<div class="tile_multiple_choice_answer"></div>').addClass(subtype);
    $(".multiple_choice_group").append(answer); 
    addToShowAndEditContainers(answer, answerList, correct, i)
  }

  function addToShowAndEditContainers(answer, answerList, correct, i){
    answer.append(showAnswerContainer("block", answerList[i], correct));
    answer.append(editAnswerContainer("none", answerList[i], i, correct));
  }

  function showQuestionAndAnswers(subtype) {
    $(".quiz_content").html("");
    quiz_content = $(".quiz_content");
    addQuestion(quiz_content, subtype["question"]);
    addAnswers(quiz_content, subtype["answers"], subtype["correct"]);
  };

  function buildContainer(display, text, html) {
    var container = $(html); 
    container.html(text);
    if(display.length > 0 ){
      container.css("display", display);
    }
    return container;
  };

  function showSlider(){
    $(sliderSelector).css("display", "block");
  }

  function initQuestionLostFocus(){
    $('body').click(function(event) {
      //FIXME hak hack hack !!!!
      if(tileBuilderForm.length>0) {
        if(!$(event.target).attr("data-dropdown")){
          closeMenuDropDowns();
        }
        if($("li.selected").length > 0){ 
          tryTurnOffEditAnswer(event.target);
        }
      }

    });
  }

  function initRemoveAnswer(){
    $("body").on("click", delAnswerSelector, function(event){
      $(this).parents(multipleChoiceAnswerSelector).remove();

    });
  }


  function closeMenuDropDowns(){
    $(dropdownSelector).each(function() {
      $(this).removeClass("open").removeAttr("style");
    });
  }

  function initQuestionTypeMenus(){
    $("body").on("click", typeSelector, function(){
     closeMenuDropDowns();
      $(this).addClass("open");
    });
  }

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
      e.stopPropagation();
      e.stopImmediatePropagation();
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
  }

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
    var answer = text ==="" ? "Add Answer Option" : text;
    container = buildContainer(display, answer, '<a class="answer_text"></a>');

    if(correct){
      container.addClass("clicked_right_answer");
    }
    return container;
  };

  function editAnswerContainer(display, text, index, correct) {
    var type = $(".selected.button").attr("id");
    var subType = findTileSubtype();
    var containerDisplay;
    var edit_answer_container = $('<ul class="answer_option"></ul>');
    var option_radio = $(
      ['<li class="option_radio">',
        '<input class="correct-answer-button answer-part" id="tile_builder_form_correct_answer_index_' + index,
        '" name="tile_builder_form[correct_answer_index]" type="radio" value="' + index, '">',
        '</li>'].join(''));

        var option_input = $(
          ['<li class="option_input">',
            '<div class="answer-div">',
            '<input placeholder="Answer Option" class="answer-field answer-part" data="' + index,
            '" maxlength="50" name="tile_builder_form[answers][]" type="text">',
            '</div>',
            '</li>'].join(''));

            if(type == "Quiz") {
              edit_answer_container.append(option_radio);
            };

            edit_answer_container.append(option_input);
           
            if(subType !=="true_false" && subType !== "rsvp_to_event"){ 
              edit_answer_container.append($("<li class='del-answer'> <i class='fa fa-remove fa-1x'></i></li>"));
              containerDisplay = "block";
            }else{
              containerDisplay = display;
            }

            text_input = edit_answer_container.find(".answer-field.answer-part");
            text_input.val(text);


            edit_answer_container.css("display", 'block');
            if(correct){
              edit_answer_container.find(".option_radio").addClass("option_selected");
              edit_answer_container.find(".correct-answer-button.answer-part").attr("checked", true);
            }
            return edit_answer_container;
  };

  function overrideDisplay(type, display){
    return type == "Quiz" ? "block" : display;
  }


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


  function addAnswerSelectedMessage(container) {
    answer_container = $('<div class="choose_answer"></div>');
    container.append(answer_container);
  }

  function showAddAnswer(container) {
    add_container = $('<div class="add_answer"></div>');
    icon = $('<i class="fa fa-plus"></i>');
    meassage = "  Add another answer";
    add_container.text(meassage).prepend(icon);
    container.append(add_container);
  }

  function showSelectAndAddAnswer(type, subtype) {
    after_answers = $('<div class="after_answers"></div>');
    if(type == "Quiz"){
      addAnswerSelectedMessage(after_answers);
    }else{
      after_answers.append('<div class=""></div>');
    }
    if(subtype == "multiple_choice" && (type == "Quiz" || type == "Survey")){
      showAddAnswer(after_answers);
    }
    $(".quiz_content").append(after_answers);
  }

  function makeButtonsSelected(type, subtype) {

    $(".button.selected").removeClass("selected");
    $(".subtype.selected").removeClass("selected");

    $("#" + type).addClass("selected");
    $("#" + subtype).addClass("selected");
  }

  function saveQuestionChanges(question_filed) {
    var type = findTileType();
    var subtype = findTileSubtype();

    tileTypes[type][subtype]["question"] = $(question_filed).val();
    $(".tile_question").html(tileTypes[type][subtype]["question"]);
  }

  function getAnswerIndex(answer_input){
    return $(answer_input).attr("data");
  }

  function updateShowAnswer(text, answer_input){
    $(answer_input).closest(".tile_multiple_choice_answer").find("a").html(text);
  }

  function saveAnswerChanges(answer_input) {
    var type = findTileType();
    var subtype = findTileSubtype();
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
    var container = $(answer_show).parent(".tile_multiple_choice_answer"), type = findTileType();
    container.find(".answer_option").css("display", "block");

    if(type == "Quiz" || type =="Survey"){ 
      container.find(".option_input").css("display", "list-item");
    }else{
      $(answer_show).css("display", "none");
      container.find(".option_input").css("display", "list-item");
    }

    allowEditOnly(container);
  }

  function allowEditOnly(container){
    container.find(".del-answer").hide();
    highlightText(container.find(".answer-field"));
  }


  function turnOffEditQuestion() {
    $(".tile_question").css("display", "block");
    $("#tile_builder_form_question").css("display", "none");
  }

  function turnOffEditAnswer(answer_div) {

    // FIXME hack to keep form elements visible for multiple choice tiles
    var type = findTileType();

    if(type == "Quiz" || type =="Survey"){ 
      $(answer_div).find(".option_input").css("display", "none")
    }else{
      $(answer_div).find("a").css("display", "block");
      $(answer_div).find(".answer_option").css("display", "none");
    }
    $(answer_div).find(".del-answer").show();
  }

  function tryTurnOffEditAnswer(element) {
    $(".tile_multiple_choice_answer").each(function() {
      if( !$(this).is( $(element).closest(".tile_multiple_choice_answer") ) ) {
        turnOffEditAnswer(this);
      };
    });
  }

  function initTileQuestion(){
    $("body").on("blur", "#tile_builder_form_question", function(event){
      //FIXME hack to get this fucking horrible code to work.
      var question =$(this);
      if((question.val().trim() ==="")){
        question.valid();
      }else{
        turnOffEditQuestion();
      }
    });
  }

  function initTileAnswer(){
    $("body").on("blur", "input[name='tile_builder_form[answers][]']", function(event){

      var answer =$(this);
      var container = $(answer).parents(".tile_multiple_choice_answer");
      var answerText = container.find(".answer_text");
      if((answer.val().trim() ==="")){
        answer.focus();
        answer.valid(); //trigger jquery validate functionality
        answer.val("Add Answer Option");
        saveAnswerChanges(answer);
        turnOnEditAnswer(answerText);

      }else{
        $("li.subtype").removeAttr("disabled")
        turnOffEditAnswer();
      }

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
    saveRightAnswer(element);
  }

  function saveRightAnswer(element) {
    var type = findTileType();
    var subtype = findTileSubtype();

    if($(element).hasClass("option_selected")){
      correct = $(element).find("input").val();
    }else {
      correct = -1;
    }
    tileTypes[type][subtype]["correct"] = correct;
  }

  function saveTypeToForm() {
    var type = findTileType();
    var subtype = findTileSubtype();

    $("#tile_builder_form_question_type").val(type);
    $("#tile_builder_form_question_subtype").val(subtype); 
  }

  function initialTypeSetUp(){
    if(tileHasQuestionType == true){
      $("#" + defaultType + "-" + defaultSubtype).click().click();
      $(".slider").css("display", "block");
    }
  }

  function setUp() {
    var config = tileTextContainer.data('questionConfig');
    tileHasQuestionType = config.hasQuestionType;
    defaultType = config.type;
    defaultSubtype = config.subType;

    _.each($('.answer-field'), addCharacterCounterFor);
    turnRadioGreen();
    initialTypeSetUp(tileHasQuestionType, defaultType, defaultSubtype);
  }

  function getTileTypes(){
    tileTypes=  tileTextContainer.data('tileTypes');
  }

  function initJQueryObjects(){
    tileTextContainer = $(tileTextContainerSelector);
    tileBuilderForm = $(tileBuilderFormSelector);
  }
  function init (){
    initJQueryObjects();
    getTileTypes();
    initQuestionTypeMenus();
    initSubType();
    initQuestionLostFocus();
    initTileQuestion();
    initTileAnswer();
    initRemoveAnswer();
    setUp();
  }

  return {
    init: init
  }

}());
