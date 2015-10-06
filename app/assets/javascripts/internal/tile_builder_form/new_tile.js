var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var tileModal
    , imagesModal
    , libaryLoaded
    , preventCloseMsg
    , modalTrigger
    , modalContent
    , tileBuilderForm
    , validator
    , tileBuilderSubmitButton
    , isExistingTile = false
    , keepOpen = false
    , tileBuilderCloseSelector = "#tilebuilder_close"
    , imageLibraryCloseSelector = "#image_library_close"
    , visileTilePlaceholderSelector = ".tile_container.placeholder_container:visible"
    , tilePreviewStatusSelector = "#preview_tile_status"
    , tileWrapperSelector =".tile_container"
    , modalContentSelector = "#modal_content"
    , sectionSelector = ".manage_section"
    , newSelector// = "a#add_new_tile"
    , editSelector = ".tile_buttons .edit_button>a, .preview_menu_item.edit>a"
    , previewSelector = ".tile-wrapper a.tile_thumb_link"
    , tileNavigationSelector = "#prev, #next"
    , tileModalSelector = "#new_tile_modal"
    , imagesModalSelector ="#images_modal"
    , addImageSelector ="#image_uploader"
    , tileBuilderFormSelector ="#new_tile_builder_form"
    , tileBuilderSubmitButtonSelector = '#new_tile_builder_form input[type=submit]'
    , ajaxHandler = Airbo.AjaxResponseHandler
    , modalActivationSelectors = [editSelector, previewSelector, tileNavigationSelector].join(",")
    , submitSuccess
  ;

 function prepEditOrNew(action){
   $("body").removeClass("client_admin-tiles-show").addClass("client_admin-tiles-edit");;
   preventCloseMsg = action
   tileBuilderSubmitButton= $(tileBuilderSubmitButtonSelector);
   tileBuilderForm = $(tileBuilderFormSelector);
   initFormValidator(tileBuilderForm);

   //TODO create funciton for setup that needs to take place only after the
   //modal has opened

   Airbo.TileImagesMgr.init();
   Airbo.TileImageCredit.init();
   Airbo.TilePointsSlider.init();
   Airbo.TileQuestionBuilder.init();
   enableCloseModalConfirmation();
   Airbo.TileSuportingContentTextManager.init();
 }


 function disableCloseModalConfirmation(){
   $(tileBuilderCloseSelector).removeAttr("data-confirm");
 }

 function enableCloseModalConfirmation(){
   $(tileBuilderCloseSelector).attr("data-confirm", "");
 }

 function prepShow(){

   $("body").addClass("client_admin-tiles-show").removeClass("client_admin-tiles-edit");

   Airbo.TileCarouselPage.init();
   initPreviewMenuTooltips();
   disableCloseModalConfirmation();
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
     functionReady: prepareToolTip,
     trigger: "click",
     autoClose: false,
   });
 }


 function shouldAutoClose(){
   return Airbo.Utils.urlParamValueByname("dactt") ? false : true;
 }

 function initSharing(){
   Airbo.TileSharingMgr.init();
   Airbo.TileTagger.init({
       submitSuccess:  function(data){
         refreshCurrentPreview(data.preview);
         prepShow();
         updateTileSection(data);
         $(".tipsy.explore").tooltipster("show");
       },
     }
   );
 }

 function prepareToolTip(origin, content){
   initSharing();
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
   var selector , section = pageSectionByStatus(data.tileStatus);
   if(isExistingTile){
     replaceTileContent(data)
   } else{
     section.prepend(data.tile); //Add tile to section
     setPlaceHolders(section);
   }
 }

 function setPlaceHolders(section){
  var node, placeHolders = section.find(visileTilePlaceholderSelector);
  if(placeHolders.length > 0){
     placeHolders.last().remove();
  }else if (placeHolders.length ===1){
    //do nothing
  }else if (placeHolders.length ===0){
     node = $(".no_tiles_section .tile_container.placeholder_container").first();
     node.css("display", "block");
     for (var i = 0; i<5; i++){
       section.append(node.clone());
     }
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

   tileModal.find(modalContentSelector).empty().append(modalContent);
   processEvent(action);
   openTileFormModal();
 }

   function initNewTileModal(){

    $("body").on("click", modalActivationSelectors, function(event){
      var img, imgHeight;
      event.preventDefault();


      modalTrigger = $(this);

      isExistingTile = modalTrigger.is(newSelector) ? false : true;
      $.ajax({
        type: "GET",
        dataType: "html",
        url: modalTrigger.attr("href") ,
        success: function(data, status,xhr){
          modalContent = $(data);
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
        imagesModal.find(modalContentSelector).append($(data));
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
        ajaxHandler.submit(form, submitSuccess, enableTileBuilderFormSubmit);
      }else{

        validator.focusInvalid();
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
          maxTextLength: 600
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

      invalidHandler: function(form, validator) {
        var errors = validator.numberOfInvalids();
        if (errors) {
          if($(validator.errorList[0].element).is(":visible"))
            {
              $('html, body').animate({
                scrollTop: $(validator.errorList[0].element).offset().top
              }, 250);
            }
            else
              {

                $('html, body').animate({
                  scrollTop: $("#" + $(validator.errorList[0].element).data("proxyid")).offset().top
                }, 1000);
              }
        }
      },

      messages: {
        "tile_builder_form[question_subtype]": "Question option is required.",
        "tile_builder_form[correct_answer_index]": "Please select one choice as the correct answer.",
        "tile_builder_form[answers][]": "Please provide text for all answer options."
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
        if($(element).attr("name")=="tile_builder_form[correct_answer_index]" && $(".after_answers label:visible").length >0){
          return;
        }else{
          $(element).parents(".content_sections").removeClass(errorClass);
        }
      }
    },

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    validator = form.validate(config);
  }

  function refreshTileDataForUser(data) {
    console.log(data);
  }

  function refreshTileDataPageWide(data){
    preventCloseMsg = false; // Allow modal to be closed sans confirmation
    refreshCurrentPreview(data.preview)
    prepShow();
    updateTileSection(data);
    scrollPageToTop();
  }

  function refreshCurrentPreview(content){
    tileModal.find(modalContentSelector).html(content);
  }

  function enableTileBuilderFormSubmit(){
    tileBuilderSubmitButton.removeAttr("disabled");
  }

  function disableTileBuilderFormSubmit(){
    tileBuilderSubmitButton.attr("disabled", "disabled");
  }


  function tileByStatusChangeTriggerLocation(target){
    var criteria = "[data-tile-id=" + target.data("tileid") + "][data-status='draft']"

    if(target.parents(tileWrapperSelector).length !== 0){
      //Trigger directly by action button on the tile outside of the modal
      return target.parents(tileWrapperSelector)
    }else if(modalTrigger.parents(tileWrapperSelector).length !=0){
      //Triggered inside modal of a prexisting tile
      return modalTrigger.parents(tileWrapperSelector);
    }else{
      //newly created tile so no trigger was present prior to the tile being created. Assume it is currently in dreaft
      return $(tileWrapperSelector).filter(criteria);
    }

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
          closeModal(tileModal);
          moveTile(tile, data);
          if((target).parents(".tooltipster-base").length > 0){
            $("li#stat_toggle").tooltipster("hide");
          }
        },

      });


    });
  }

  function initImageLibraryModal(){
    $("body").on("click", addImageSelector, function(event){
      event.preventDefault();
      if(libaryLoaded){
        openImageSelectorModal();
      }else{
        getImageLibrary($(this).data("libraryUrl"));
      }

      disableCloseModalConfirmation();
    });
  }

 function initDeletionConfirmation(){
   $("body").on("confirm.reveal", "a[data-confirm]", function(event){
     preventCloseMsg=false;
     $(this).parents(".reveal-modal").foundation("reveal", "close");
   });

   //TODO figure why this needs a timer
   $("body").on("cancel.reveal", "a#tilebuilder_close[data-confirm]", function(event){
     setTimeout(function(){setupModalFor()}, 200);
   });
 }

 function scrollPageToTop(){
   $("body").scrollTop(0);
 }



 function tileModalOpenClose(){

   $(document).on('open',tileModalSelector, function () {
     scrollPageToTop();
     $("body").css({"overflow-y": "hidden"});
   });

   $(document).on('opened',tileModalSelector, function () {
    Airbo.Utils.mediumEditor.init();
   });

   $(document).on('closed', tileModalSelector, function (event) {

     if(keepOpen){
        openTileFormModal();
     }else{
      $("body").css({"overflow": ""});
     }
   });


   $(document).on('close', tileModalSelector, function (event) {
     var msg;
     if(preventCloseMsg){

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
      enableCloseModalConfirmation();
    });

    $(document).on('close.fndtn.reveal', imagesModalSelector, function (event) {
      //noop
    });

    $(document).on('opened.fndtn.reveal',imagesModalSelector, function () {
      $("body").css({"overflow-y": "hidden"});
    });

  }


  function openTileFormModal(){
    tileModal.foundation("reveal", "open", {animation: "fade",closeOnBackgroundClick: true });
    initCancelBeforeSave();
  }

  function initCancelBeforeSave(){
    var msg = "Are you sure you want to stop " + preventCloseMsg + " this tile?"
    + " Any changes you've made will be lost.",
    config = $.extend({}, Airbo.Utils.confirmWithRevealConfig, {body: msg});
    $("#tilebuilder_close").confirmWithReveal(config);
  }

  function openImageSelectorModal(){
    imagesModal.foundation("reveal", "open", {animation: "fade", closeOnBackgroundClick: true});
  }

  function initModalOpenClose(){
    tileModalOpenClose();
    imagesModalOpenclose();
  }

  function closeModal(modal){
   modal.foundation("reveal", "close");
  }

  function initJQueryObjects(){
    tileModal = $(tileModalSelector);
    imagesModal = $(imagesModalSelector);
  }

  function initContext(context) {
    newSelector = context.newSelector;
    modalActivationSelectors += ", " + newSelector;
    if(context.submitSuccessName == "refreshTileDataPageWide"){
      submitSuccess = refreshTileDataPageWide;
    } else {
      submitSuccess = refreshTileDataForUser;
    }
  }

  function init(context){
    initContext(context);

    initDeletionConfirmation();

    initStatusUpdate();

    initModalOpenClose();

    initJQueryObjects();

    initNewTileModal();

    initImageLibraryModal();

    initTileBuilderFormSubmission();

    $(tileModalSelector).click(function(event){
      if($(event.target).is(tileModalSelector) || $(event.srcElement).is(".tile_preview_container") || $(event.srcElement).is(".row")){
        $(tileBuilderCloseSelector).trigger("click");
      }
    });


    $(imagesModalSelector).click(function(event){
      if($(event.target).is(imagesModalSelector) || $(event.srcElement).is(".tile_preview_container") || $(event.srcElement).is(".row")){
        $(imageLibraryCloseSelector).trigger("click");
      }
    });


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


  // function blockSubmitButton (counter) {
  //   var errorContainer, submitBtn, textLeftLength;
  //   textLeftLength = contentEditor.text().length;
  //   submitBtn = $("#publish input[type=submit]");
  //   errorContainer = $(".supporting_content_error");
  //   if (textLeftLength > contentEditorMaxlength()) {
  //     submitBtn.attr('disabled', 'disabled');
  //     errorContainer.show();
  //   } else {
  //     submitBtn.removeAttr('disabled');
  //     errorContainer.hide();
  //   }
  // }

  function updateContentInput() {
    contentInput.val(contentEditor.html());
  }

  function initializeEditor() {
    var pasteNoFormattingIE;
    addCharacterCounterFor('#tile_builder_form_headline');
    addCharacterCounterFor(contentEditorSelector);
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

var TileCreatorContext = {
  client_admin: {
    newSelector: "a#add_new_tile",
    submitSuccessName: "refreshTileDataPageWide"
  },
  suggestion_box: {
    newSelector: "a#submit_tile",
    submitSuccessName: "refreshTileDataForUser"
  }
}


$(function(){
  context = $("#new_tile_modal").data("context");
  if(context) {
    Airbo.TileCreator.init(TileCreatorContext[context]);
  }
})
