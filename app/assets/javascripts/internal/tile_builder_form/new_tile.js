var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var tileModal
    , imagesModal
    , libaryLoaded
    , preventCloseMsg
    , modalTrigger
    , modalContent
    , tileBuilderForm
    , tileBuilderSubmitButton
    , inExistingTile = false
    , keepOpen = false
    , tilePreviewStatusSelector = "#preview_tile_status"
    , tileWrapperSelector =".tile_container"
    , modalContentSelector = "#modal_content"
    , modalBackgroundSelector = '.reveal-modal-bg'
    , sectionSelector = ".manage_section"
    , newSelector = "a#add_new_tile, #add_new_tile.preview_menu_item a"
    , editSelector = ".tile_buttons .edit_button>a, .preview_menu_item.edit>a"
    , previewSelector = ".tile-wrapper a.tile_thumb_link"
    , tileNavigationSelector = "#prev, #next"
    , tileModalSelector = "#new_tile_modal"
    , imagesModalSelector ="#images_modal"
    , addImageSelector ="#image_uploader"
    , tileBuilderFormSelector ="#new_tile_builder_form"
    , tileBuilderSubmitButtonSelector = '#new_tile_builder_form input[type=submit]'
    , ajaxHandler = Airbo.AjaxResponseHandler
    , modalActivationSelectors = [newSelector, editSelector, previewSelector, tileNavigationSelector].join(",")
  ;

 function prepEditOrNew(action){
   $("body").removeClass("client_admin-tiles-show").addClass("client_admin-tiles-edit");;
   preventCloseMsg = action
   tileBuilderSubmitButton= $(tileBuilderSubmitButtonSelector);
   tileBuilderForm = $(tileBuilderFormSelector);
   initFormValidator(tileBuilderForm);

   Airbo.TileImageCredit.init();
   Airbo.TilePointsSlider.init();
   Airbo.TileSuportingContentTextManager.init();
   Airbo.TileQuestionBuilder.init();
 }

 function prepShow(){

   $("body").addClass("client_admin-tiles-show").removeClass("client_admin-tiles-edit");
   $(".tile_preview_container").removeClass("large-9").addClass("large-12");

   Airbo.TileCarouselPage.init();
   initPreviewMenuTooltips();
 }

 function tooltipBefore(){
   console.log($(this).tooltipster("content"))
 }

 function initPreviewMenuTooltips(){
   $(".tipsy").tooltipster({
     theme: "tooltipster-shadow",
     interactive: true,
     position: "bottom",
     contentAsHTML: true,
     functionReady: initSharing,
     autoClose: true,
   });
 }

 function initSharing(){
   Airbo.TileSharingMgr.init();
   Airbo.TileTagger.init();
 }


 function moveTile(currTile, data){
   var newTile = $(data) 
     , status = newTile.data("status")
     , newSection = "#" + status + sectionSelector
   ;

   currTile.remove();

   $(newSection).prepend(newTile);
 }

 function updateTileSection(data){

   var selector
     , section = pageSectionByStatus(data.tileStatus);
   ;
   if(inExistingTile){
     replaceTileContent(data)
   } else{
     section.prepend(data.tile); //Add tile to section
   }
 }

 function replaceTileContent(data){
   selector = tileWrapperSelector + "[data-tile-id=" + data.tileId + "]";
   $(selector).replaceWith(data.tile);
 }

 function pageSectionByStatus(status){
   return $("#" + status + sectionSelector);
 } 


 function processEvent(action){

   switch(action){
     case "new":
       prepEditOrNew("creating");
     break;
     case "edit":
       prepEditOrNew("editing");
     break;
     case "show":
       prepShow();
       break;
     default:
       // code
   }
 }

 function setupModalFor(action){
   action = action || modalTrigger.data("action");

   tileModal.find(modalContentSelector).html(modalContent);

   processEvent(action);
   openTileFormModal();
 }

 function initDeletionConfirmation(){
   $("body").on("confirm.reveal", "a[data-confirm]", function(event){

   });

   //TODO figure why this needs a timer
   $("body").on("cancel.reveal", "a[data-confirm]", function(event){
     setTimeout(function(){setupModalFor()}, 200);
   });
 }


  function initNewTileModal(){

    $("body").on("click", modalActivationSelectors, function(event){
      event.preventDefault(); 
      modalTrigger = $(this);
      inExistingTile = true
      $.ajax({
        type: "GET",
        dataType: "html",
        url: modalTrigger.attr("href") ,
        success: function(data, status,xhr){
          modalContent = data;
          setupModalFor(modalTrigger.data("action"));
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }



  function getImageLibrary(libaryUrl){
    $.ajax({
      type: "GET",
      dataType: "html",
      url: libaryUrl,
      success: function(data, status,xhr){
        imagesModal.html(data);
        openImageSelectorModal();
        Airbo.TileImagesMgr.init();
        libaryLoaded = true;
      },
      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    })
  }

  function initTileBuilderFormSubmission(){

    $("body").on("submit", tileBuilderFormSelector, function(event){
      event.preventDefault(); 
      var form = $(this);

      if(form.valid()){
        disableTileBuilderFormSubmit();
        ajaxHandler.submit(form, refreshTileDataPageWide, enableTileBuilderFormSubmit);
      }
    });
  }


  function initFormValidator(form){
    var config ={

      debug: true,

      ignore: [],

      errorClass: "tile_builder_error",

      rules: {
        "tile_builder_form[supporting_content]": {
          required: true,
          minWords: 1,
        },

        "tile_builder_form[headline]": {
          required: true,
        },

        "tile_builder_form[remote_media_url]": {
          required: true,
        },

        "tile_builder_form[question_subtype]": {
          required: true,
        },

        "tile_builder_form[question]": {
          required:  true,
        },

        "tile_builder_form[correct_answer_index]": {
          required:  true,
        },

        "tile_builder_form[answers][]": {
          required: true,
        }

      },

      messages: {
        "tile_builder_form[question_subtype]": "Question option is required",
        "tile_builder_form[correct_answer_index]": "Please select one choice as the correct answer",
        "tile_builder_form[answers][]": "Please provide text for all answer options"
      },

      errorPlacement: function(error, element) {

        if(element.attr("name")=="tile_builder_form[question_subtype]"){
          error.insertAfter(".quiz_content>.placeholder");
        }
        else if( element.attr("name")=="tile_builder_form[correct_answer_index]"){
          $(".after_answers").prepend(error);
        } 
        else if( element.attr("name")=="tile_builder_form[answers][]"){
          element.parents(".multiple_choice_group").append(error);
        } 
        else {

          element.parent().append(error);
        }
      },

      highlight: function(element, errorClass) {

        $(element).parents(".content_sections").addClass(errorClass);
      },

      unhighlight: function(element, errorClass) {
        $(element).parents(".content_sections").removeClass(errorClass);
        $(element.form).find("label[for=" + element.id + "]").addClass(errorClass);
      }
    },

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    validator = form.validate(config);
  }


  function refreshTileDataPageWide(data){
    preventCloseMsg = false; // Allow modal to be closed sans confirmation
    tileModal.find(modalContentSelector).html(data.preview);
    prepShow();
    updateTileSection(data);
  }

  function enableTileBuilderFormSubmit(){
    tileBuilderSubmitButton.removeAttr("disabled");
  }

  function disableTileBuilderFormSubmit(){
    tileBuilderSubmitButton.attr("disabled", "disabled");
  }


  function tileByStatusChangeTriggerLocation(target){
    var tile = target.parents(tileWrapperSelector)
    return tile.length==0 ? modalTrigger.parents(tileWrapperSelector) : tile
  }

  function initStatusUpdate(){
    $("body").on("click", ".update_status", function(event) {
      event.preventDefault();

      var tile, target = $(this) ;

      tile = tileByStatusChangeTriggerLocation(target);

      $.ajax({
        url: target.attr("href"),
        type: "put",
        data: {"update_status": target.data("status")},
        dataType: "html",
        success: function(data, status,xhr){
          moveTile(tile, data);
          $(modalBackgroundSelector).trigger("click");
        },

      });
    });
  }


  function initImageLibraryModal(){
    $("body").on("click", addImageSelector, function(event){
      event.preventDefault();
      if(libaryLoaded){
        Airbo.TileImagesMgr.init();
        openImageSelectorModal();
      }else{
        getImageLibrary($(this).data("libraryUrl"));
      }
    });
  }


 function tileModalOpenClose(){

   $(document).on('open.fndtn.reveal',tileModalSelector, function () {
     var modalHeight = tileModal.height() + 300;
     $("body").scrollTop(50)
     $(".main").css({"max-height": modalHeight, "overflow-y": "hidden"});

   });

   $(document).on('opened.fndtn.reveal',tileModalSelector, function () {
     $('.reveal-modal-bg').css({'background-color':'#212C33', 'opacity': 0.9});
   });

   $(document).on('closed.fndtn.reveal', tileModalSelector, function (event) {
     if(keepOpen){
        openTileFormModal();
     }else{
      inExistingTile = false;
      $(".main").css({"max-height": "", "overflow": ""});
     }
   });


   $(document).on('close.fndtn.reveal', tileModalSelector, function (event) {
     var msg;
     if(preventCloseMsg){

       msg = "Are you sure you want to stop " + preventCloseMsg + " this tile?"
       + "\nAny changes you've made will be lost."
       + "\n\nClick 'cancel' to continue " + preventCloseMsg + " this tile."
       + "\n\nOtherwise click 'Ok' to discard your changes.";

       if (confirm(msg)){
         keepOpen = false;
         preventCloseMsg = undefined;

       }else{
         keepOpen = true;
       }
     }
   });
 }

  function imagesModalOpenclose(){
    $(document).on('closed.fndtn.reveal', imagesModalSelector, function () {
      openTileFormModal();
    });
  }


  function openTileFormModal(){
    tileModal.foundation("reveal", "open", {animation: "fade"});
    keepOpen = false;
  }

  function openImageSelectorModal(){
    imagesModal.foundation("reveal", "open", {animation: "fade"});
  }

  function initModalOpenClose(){
    tileModalOpenClose();
    imagesModalOpenclose();
  }

  function initJQueryObjects(){
    tileModal = $(tileModalSelector);
    imagesModal = $(imagesModalSelector);
  }


  function init(){

    initDeletionConfirmation();

    initStatusUpdate();

    initModalOpenClose();

    initJQueryObjects();

    initNewTileModal();

    initImageLibraryModal();

    initTileBuilderFormSubmission();
  }



  return {

    init: init

  };

}());


Airbo.TileCarouselPage = (function() {

  function updateNavbarURL(newTileId) {
    var newURL, tag;
    newURL = newTileId.toString();
    tag = getURLParameter('tag');
    if (tag != null) {
      newURL += "?tag=" + tag;
    }
    return History.pushState(null, null, newURL);
  }

  function getURLParameter(sParam) {
    var i, j, ref, sPageURL, sParameterName, sURLVariables;
    sPageURL = window.location.search.substring(1);
    sURLVariables = sPageURL.split('&');
    for (i = j = 0, ref = sURLVariables.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] === sParam) {
        return sParameterName[1];
      }
    }
  }

  function setUpAnswersForPreview() {
    attachRightAnswersForPreview();
    attachWrongAnswers();
  }

  function attachRightAnswersForPreview() {
    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      rightAnswerClickedForPreview(event);
      disableAllAnswers();
    });
  }

  function attachWrongAnswer(answerLink, target) {
    return answerLink.click(function(event) {
      event.preventDefault();
      target.html("Sorry, that's not it. Try again!");
      target.slideDown(250);
      return $(this).addClass("clicked_wrong");
    });
  }

  function attachWrongAnswers( ) {
    return _.each($('.wrong_multiple_choice_answer'), function(wrongAnswerLink) {
      var target;
      wrongAnswerLink = $(wrongAnswerLink);
      target = wrongAnswerLink.siblings('.answer_target');
      return attachWrongAnswer(wrongAnswerLink, target);
    });
  }


  function markCompletedRightAnswer(event) {
    return $(event.target).addClass('clicked_right_answer');
  };

  function rightAnswerClickedForPreview(event) {
    markCompletedRightAnswer(event);
    attachRightAnswerMessage(event);
  };

  function disableAllAnswers() {
    return $(".right_multiple_choice_answer").removeAttr("href").unbind();
  }

  function attachRightAnswerMessage(event) {
    if ( $(".tile_multiple_choice_answer").length == 1) {
      return $(event.target).siblings('.answer_target').html("Correct!").slideDown(250);
    }
  }

  function init(){
    grayoutTile();
    //updateNavbarURL(data.tile_id);
    setUpAnswersForPreview();
    ungrayoutTile();
  }
  return {
    init: init
  }

}());


Airbo.TileSuportingContentTextManager = (function(){

  var contentEditor
    , contentInput
    , contentEditorSelector = '#supporting_content_editor'
    , contentInputSelector = '#tile_builder_form_supporting_content'
  ;

  function contentEditorMaxlength() {
    return contentEditor.next().attr('maxlength');
  };


  function blockSubmitButton (counter) {
    var errorContainer, submitBtn, textLeftLength;
    textLeftLength = contentEditor.text().length;
    submitBtn = $("#publish input[type=submit]");
    errorContainer = $(".supporting_content_error");
    if (textLeftLength > contentEditorMaxlength()) {
      submitBtn.attr('disabled', 'disabled');
      errorContainer.show();
    } else {
      submitBtn.removeAttr('disabled');
      errorContainer.hide();
    }
  }

  function updateContentInput() {
    contentInput.val(contentEditor.html());
  }

  function initializeEditor() {
    var pasteNoFormattingIE;
    addCharacterCounterFor('#tile_builder_form_headline');
    addCharacterCounterFor(contentEditorSelector);
    Airbo.Utils.mediumEditor.init();
  };

  function initjQueryObjects(){
    contentEditor = $(contentEditorSelector);
    contentInput = $(contentInputSelector);
  }


  function init(){

    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(contentEditorSelector) ) {
      initjQueryObjects();
      initializeEditor();
      return this;
    }
  }

  return {
    init: init
  }


}());


$(function(){
Airbo.TileCreator.init();
})
