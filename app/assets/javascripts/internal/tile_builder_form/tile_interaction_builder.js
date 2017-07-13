var Airbo = window.Airbo || {};


Airbo.TileInteractionManager =(function(){

  var tileTypes = []
    , tilebuilderform
    , tileBuilderFormSelector = "#new_tile_builder_form"
    , sliderSelector = ".slider"
  ;


  function initDom(){
    tileBuilderForm = $(tileBuilderFormSelector);
  }


  function showSlider(){
    $(sliderSelector).css("display", "block");
  }

  function saveTypeToForm(config) {
    $("#tile_question_type").val(config.type);
    $("#tile_question_subtype").val(config.subtype);
    tileBuilderForm.change();
  }


  function resetQuizCorrectAnswerIndex(){
    $("#quiz-answer input[type='radio']").each(function(idx, option){
       $(option).val(idx);
    })
    tileBuilderForm.change();
  }


  function renderSelectedInteraction(config){
    Airbo.TileInteractionBuilder.init(config);
    Airbo.TileInteractionBuilder.render();

    Airbo.TileInteractionMenuHandler.setSelected(config.type,config.subtype);
    saveTypeToForm(config);
    autosize($('#tile_question'));
    autosize($('textarea.answer-editable'));
  }

  function getSavedOrDefaultInteractionConfig(){
    var defaults
      , config ={}
      , savedConfig = $("#question_type_container").data('config')
    ;

    if(Object.keys(savedConfig).length === 0){
      defaults = Airbo.TileBuilderInteractionConfig.defaultKeys();
      config = interactionConfigByTypeAndSubType(defaults);
      $("#question_type_container").data('config', config)
    }else{
      config = interactionConfigByTypeAndSubType(savedConfig);
      config =  $.extend({}, config, savedConfig)
      $("#question_type_container").data('config', config)
    }

    return config;
  }


  function interactionConfigByTypeAndSubType(selected){
    var config = Airbo.TileBuilderInteractionConfig.get(selected.type, selected.subtype);

    config.type = selected.type
    config.subtype = selected.subtype
    return config;
  }


  function handleSubTypeSelection(selected){
    var config = interactionConfigByTypeAndSubType(selected);
    renderSelectedInteraction(config)
    initFreeFormTooltip();
  }

  function initAddAnswerOption(){
    $("body").on("click", ".js-add-answer", function(event){
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      Airbo.TileInteractionBuilder.addAnswer();
    })
  }

  function initRemoveAnswerOption(){
    $("body").on("click", ".js-remove-answer", function(event){
      event.preventDefault();
      $(this).parents(".answer-div").remove();
      resetQuizCorrectAnswerIndex();
    })
  }

  function highlightText(input) {
    input.focus();
    input.select();
  }

  function initAnswerEdit(){
    $("body").on("click", ".js-answer-btn", function(event){
      event.preventDefault();
      var answer = $(this).parent(".answer-div")
        , field = answer.find(".answer-editable").first()
      ;

      answer.removeClass("read-mode").addClass("edit-mode")
      field.data("text",field.val()); 
      highlightText(field)
    });
  }


  function initAnswerEditOnTabEntry(){
    $('body').on('keydown', ".answer-editable", function openNextAnswerOnTab(e) {

      var  code = e.keyCode || e.which
        , nextAnswer = $(this).parent(".answer-div").next(".answer-div")
        , field = nextAnswer.first(".answer-editable")
      ;

    if (code == '9') {
      if(nextAnswer.length > 0){
        nextAnswer.find(".js-answer-btn").click();

        highlightText(field)
        return false;
      }
    }
    });
  }

  function initQuestionitHighlight(){

    $('body').on('click', "#tile_question", function(event) {
      highlightText($(this) );
    })
  }
  function initAnswerRead(){
    $("body").on("focusout blur", ".answer-editable", function(event){
      var field = $(this)
        , answer = field.parent(".answer-div")
        , btn = answer.find(".js-answer-btn").first()
        , text = field.val()
        , storedVal= field.data("text")
        , defaultText =  "Add Ansswer Option"
      ;

      if(text.length === 0){
        if(storedVal=== "" || storedVal === undefined){
          storedVal= defaultText;
        }

         field.val(storedVal);
         btn.text(storedVal);
      }else{
        field.data("text", text);
        btn.text(text);
        answer.removeClass("edit-mode").addClass("read-mode")
      }

    });
  }

  function initToggleFreeResponse(){
    $("body").on("change", ".js-chk-free-text", function(event){
      var btnWrapper = $(".js-free-text-btn-wrapper")
        , target = event.target
      ;

      if(target.checked){
        btnWrapper.addClass("enabled");
      }else{
        btnWrapper.removeClass("enabled");
      }
    });
  }

  function initFreeFormTooltip(){
    $(".js-free-text-tooltip").tooltipster({
      theme: "tooltipster-shadow" 
    });
  }


  function init (){
    initDom();
    initAddAnswerOption();
    initRemoveAnswerOption();
    Airbo.TileBuilderInteractionMenuBuilder.render();
    Airbo.TileInteractionMenuHandler.init(handleSubTypeSelection)
    Airbo.TileBuilderCharacterCounter.init();
    renderSelectedInteraction(getSavedOrDefaultInteractionConfig());
    initAnswerEdit();
    initAnswerRead();
    initAnswerEditOnTabEntry();
    initToggleFreeResponse();
    initFreeFormTooltip();
    initQuestionitHighlight();
    showSlider();
  }

  return {
    init: init
  }
}())

