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
    , visileTilePlaceholderSelector = ".tile_container.placnexteholder_container:visible"
    , tilePreviewStatusSelector = "#preview_tile_status"
    , tileWrapperSelector =".tile_container"
    , modalContentSelector = "#modal_content"
    , sectionSelector = ".manage_section"
    , newSelector// = "a#add_new_tile"
    , editSelector = ".tile_buttons .edit_button>a, .preview_menu_item.edit>a"
    , previewSelector = ".tile-wrapper a.tile_thumb_link"
    , tileNavigationSelector = "#new_tile_modal #prev, #new_tile_modal #next"
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
   $("body").removeClass("client_admin-tiles-show").addClass("client_admin-tiles-edit");
   preventCloseMsg = action;
   tileBuilderSubmitButton= $(tileBuilderSubmitButtonSelector);
   tileBuilderForm = $(tileBuilderFormSelector);
   initFormValidator(tileBuilderForm);
   //initIntroTooltips();
   //TODO create funciton for setup that needs to take place only after the
   //modal has opened

   Airbo.TileImagesMgr.init();
   Airbo.TileImageCredit.init();
   Airbo.TilePointsSlider.init();
   Airbo.TileQuestionBuilder.init();
   enableCloseModalConfirmation();
   Airbo.TileSuportingContentTextManager.init();
   Airbo.Utils.mediumEditor.init();
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

 function initIntroTooltips(){
   $(".intro-tipsy").tooltipster({
     theme: "tooltipster-shadow",
     interactive: true,
     position: "left",
     contentAsHTML: true,
     trigger: "custom",
     positionTracker: "true",
     autoClose: false,
   });

   $("#image_uploader").tooltipster("show");

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
   sections = {
      "active": "active",
      "draft": "draft",
      "archive": "archive",
      "user_submitted": "suggestion_box",
      "ignored": "suggestion_box"
   }
   var newTile = $(data)
     , status = newTile.data("status")
     , newSection = "#" + sections[status]
   ;

  if(status !=="user_submitted" && status!=="ignored"){
    currTile.remove();
    $(newSection).prepend(newTile);
    window.updateTilesAndPlaceholdersAppearance();
  }else{
    replaceTileContent(newTile, newTile.data("tileId"));
    updateUserSubmittedTilesCounter();
  }
 }

 function updateUserSubmittedTilesCounter() {
   submittedTile = $(".tile_thumbnail.user_submitted");
   $("#user_submitted_tiles_counter").html(submittedTile.length);
 }

 function updateTileSection(data){
   var selector , section = pageSectionByStatus(data.tileStatus);
   if(isExistingTile){
     replaceTileContent(data.tile, data.tileId)
   } else{
     section.prepend(data.tile); //Add tile to section
     window.updateTilesAndPlaceholdersAppearance();
   }
 }


 function replaceTileContent(tile, id){
   selector = tileWrapperSelector + "[data-tile-id=" + id + "]";
   $(selector).replaceWith(tile);
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

      if(isIE() == 8){
        alert("Sorry, it looks like you're using an unsupported browser. Please use Chrome, Firefox, Safari or Internet Explorer 9 and above.");

        return;
      }

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

  function errorClassName(element, errorClass) {
    name = $(element).attr("name");
    switch(name) {
      case "tile_builder_form[question_subtype]":
        errorClass = "question_" + errorClass;
        break;
      case "tile_builder_form[correct_answer_index]":
        errorClass = "index_" + errorClass;
        break;
      case "tile_builder_form[answers][]":
        errorClass = "answer_" + errorClass;
        break;
    }
    return errorClass;
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
          required:  true
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
              $(tileModalSelector).animate({
                scrollTop: $(validator.errorList[0].element).offset().top
              }, 250);
            }
            else
              {

                $(tileModalSelector).animate({
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
        $(element).parents(".content_sections").addClass( errorClassName(element, errorClass) );
      },

      unhighlight: function(element, errorClass) {
        $(element).parents(".content_sections").removeClass( errorClassName(element, errorClass) );
      }
    },

    config = $.extend({}, Airbo.Utils.validationConfig, config);
    validator = form.validate(config);
  }

  function refreshTileDataForUser(data) {
    preventCloseMsg = false; // Allow modal to be closed sans confirmation
    refreshCurrentPreview(data.preview);
    prepShow();
    disableCloseModalConfirmation();
    scrollPageToTop();
  }

  function refreshTileDataPageWide(data){
    preventCloseMsg = false; // Allow modal to be closed sans confirmation
    refreshCurrentPreview(data.preview);
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
      var resp, tile, target = $(this);
      tile = tileByStatusChangeTriggerLocation(target);

      function closeAnyToolTips(){
        if((target).parents(".tooltipster-base").length > 0){
          $("li#stat_toggle").tooltipster("hide");
        }
      }

      submitTileForUpadte(tile,target, closeAnyToolTips);
    });
  }


  function submitTileForUpadte(tile,target, postProcess ){
      $.ajax({
        url: target.data("url") || target.attr("href"),
        type: "put",
        data: {"update_status": target.data("status")},
        dataType: "html",
        success: function(data, status,xhr){
          closeModal(tileModal);
          moveTile(tile, data);
          postProcess();
        },
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
   $("body").on("confirm.reveal", "a[data-confirm]:not(.accept)", function(event){
     preventCloseMsg=false;
     $(this).parents(".reveal-modal").foundation("reveal", "close");
   });

   //TODO figure why this needs a timer
   $("body").on("cancel.reveal", "a#tilebuilder_close[data-confirm]", function(event){
     setTimeout(function(){setupModalFor()}, 200);
   });
 }


 function scrollPageToTop(){
   $(tileModalSelector).scrollTop(0);
 }



 function tileModalOpenClose(){

   $(document).on('opened',tileModalSelector, function (event) {
     if($(event.target).is(tileModal)){
       scrollPageToTop();
       $("body").css({"overflow-y": "hidden"});
     }
   });

   $(document).on('closed', tileModalSelector, function (event) {
     if(keepOpen){
        openTileFormModal();
     }else{
      $("body").css({"overflow": ""})
               .removeClass("client_admin-tiles-show")
               .removeClass("client_admin-tiles-edit");
     }
   });


   $(document).on('close', tileModalSelector, function (event) {
     $(".tipsy").tooltipster("hide");
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
      $("body").css({"overflow-y": "hidden"}).addClass("client_admin-tiles-edit");
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

  function initAcceptTileConfirm(){
    var msg = "Are you sure you want to accept this tile? You cannot undo this action.";

    config = $.extend({}, Airbo.Utils.confirmWithRevealConfig, {body: msg});


    $(".accept").confirmWithReveal(config);
    $("body").on("confirm.reveal", "a.accept", function(event){

      event.preventDefault();
      var resp, tile, target = $(this);
      tile = tileByStatusChangeTriggerLocation(target);

      function closeConfirmation(){
        $(".reveal-modal.tiny.confirm-with-reveal").foundation("reveal", "close");
      }

      submitTileForUpadte(tile, target, closeConfirmation);
      return false;
    });


    $("body").on("cancel.reveal", "a.accept.preview", function(event){
      setTimeout(function(){setupModalFor("show")}, 200);
    });

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


  //FIXME not what I had in mind
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
    initAcceptTileConfirm()
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





var TileCreatorContext = {
  client_admin: {
    newSelector: "a#add_new_tile, a#submit_tile",
    submitSuccessName: "refreshTileDataPageWide"
  },
  suggestion_box: {
    newSelector: "a#submit_tile, a#create_new_tile, a.suggest_tile_redirect",
    submitSuccessName: "refreshTileDataForUser"
  }
}

$(function(){
  context = $("#new_tile_modal").data("context");
  if(context) {
    Airbo.TileCreator.init(TileCreatorContext[context]);
  }
});
