var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var tileModal
    , imagesModal
    , libaryLoaded
    , preventCloseMsg
    , modalTrigger
    , modalContent
    , currTileId
    , currTileStatus
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
    , tileForm ="#new_tile_builder_form"
    , ajaxHandler = Airbo.AjaxResponseHandler
    , modalActivationSelectors = [newSelector, editSelector, previewSelector, tileNavigationSelector].join(",")
  ;

 function prepEditOrNew(action){
   $(tileForm).data("asAjax", true);
   $("body").removeClass("client_admin-tiles-show");
   $("body").addClass("client_admin-tiles-edit");
   preventCloseMsg = action
   Airbo.TileImageCredit.init();
   Airbo.TilePointsSlider.init();
 }

 function prepShow(){
   adjustStylingForPreview();
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
     , status = newTile.find(".tile_thumbnail").data("status")
     , newSection = "#" + status + sectionSelector
   ;
   currTile.remove();
   $(newSection).prepend(newTile);
 }

 function pageSectionByStatus(status){
   return $("#" + status + sectionSelector);
 } 

 function updateTileSection(data){

   var selector
     , section = pageSectionByStatus(data.tileStatus);
   ;

   if(currTileId){
     selector = tileWrapperSelector + "[data-tile-id=" + currTileId + "]";
     $(selector).replaceWith(data.tile);
   } else{
     section.prepend(data.tile); //Add tile to section
   }
 }
 function adjustStylingForPreview(){
   $("body").addClass("client_admin-tiles-show");
   $(".tile_preview_container").removeClass("large-9").addClass("large-12");
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
      currTileId=modalTrigger.data("tileId")
      currTileStatus = modalTrigger.data("status")
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
  function initTileSubmission(){

    $("body").on("submit", "#new_tile_builder_form", function(event){
      event.preventDefault(); 
      form = $(this);
      submitButton = form.find('input[type=submit]')
      submitButton.attr("disabled", "disabled");

      if((form).data("asAjax")==true){
        $.ajax({
          url: form.attr("action"),
          type: form.attr("method"),
          data: form.serialize(),
        }).done(function(data,status,xhr){

          ajaxHandler.silentSuccess(data, status, xhr, function(data){

            preventCloseMsg = false; // Allow modal to be closed sans confirmation
            tileModal.find(modalContentSelector).html(data.preview);
            prepShow();
            updateTileSection(data);
          });

        }).fail(function(xhr, status, errorThrown){
          ajaxHandler.fail( xhr, status, function(){
            submitButton.removeAttr("disabled");
          });

        });
      }else {
        form[0].submit();
      }

    });
  }

  function initStatusUpdate(){
    $("body").on("click", ".update_status", function(event) {
      event.preventDefault();
      var tile 
        ,  target= $(this)
      ;

      tile = target.parents(tileWrapperSelector)
      tile  = tile.length==0 ? modalTrigger.parents(tileWrapperSelector) : tile

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
     $("body").scrollTop(50)
   });

   $(document).on('opened.fndtn.reveal',tileModalSelector, function () {
     $('.reveal-modal-bg').css({'background-color':'black', 'opacity': 0.85});
   });

   $(document).on('closed.fndtn.reveal', tileModalSelector, function (event) {
     if(keepOpen){
        openTileFormModal();
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

    initTileSubmission();
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




$(function(){
Airbo.TileCreator.init();
})
