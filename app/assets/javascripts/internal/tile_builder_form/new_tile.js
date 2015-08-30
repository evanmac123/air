var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var tileModal
    , imagesModal
    , libaryLoaded
    , preventCloseMsg
    , modalTrigger
    , modalContent
    , keepOpen = false
    , newSelector = "a#add_new_tile, #add_new_tile.preview_menu_item a"
    , editSelector = ".tile_buttons .edit_button>a"
    , previewSelector = ".tile-wrapper a.tile_thumb_link"
    , tileNavigationSelector = "#prev, #next"
    , tileModalSelector = "#new_tile_modal"
    , imagesModalSelector ="#images_modal"
    , addImageSelector ="#image_uploader"
    , tileForm ="#new_tile_builder_form"
    , modalActivationSelectors = [newSelector, editSelector, previewSelector, tileNavigationSelector].join(",")
  ;

 function prepEditOrNew(action){
   $(tileForm).data("asAjax", true);
   $("body").addClass("client_admin-tiles-edit");
   preventCloseMsg = action
   Airbo.TileImagesMgr.init();
 }

 function prepShow(){
   adjustStylingForPreview();
   Airbo.TileCarouselPage.init();
 }

 function adjustStylingForPreview(){
   $("body").addClass("client_admin-tiles-show");
   $(".tile_preview_container").removeClass("large-9").addClass("large-12");
 }

 function processEvent(trigger){

   switch(trigger.data("action")){
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

 function handleModal(){
   tileModal.find("#modal_content").html(modalContent);
   processEvent(modalTrigger);
   tileModal.foundation("reveal", "open");
 }

 function initDeletionConfirmation(){
   $("body").on("confirm.reveal", "a[data-confirm]", function(event){

   });

   $("body").on("cancel.reveal", "a[data-confirm]", function(event){
     setTimeout(function(){handleModal()}, 200);
   });
 }

  function initNewTileModal(){

    $("body").on("click", modalActivationSelectors, function(event){
      event.preventDefault(); 
      modalTrigger = $(this);

      $.ajax({
        type: "GET",
        dataType: "html",
        url: modalTrigger.attr("href") ,
        success: function(data, status,xhr){
          modalContent = data;
          handleModal();
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
          $(imagesModalSelector).foundation("reveal", "open");
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
        $(imagesModalSelector).foundation("reveal", "open");
      }else{
        getImageLibrary($(this).data("libraryUrl"));
      }
    });
  }

  function initJQueryObjects(){
    tileModal = $(tileModalSelector);
    imagesModal = $(imagesModalSelector);
  }

  function init(){

    initDeletionConfirmation();

    $(document).on('opened.fndtn.reveal',tileModalSelector, function () {
      $('.reveal-modal-bg').css({'background-color':'black', 'opacity': 0.85});
    });

    $(document).on('closed.fndtn.reveal', tileModalSelector, function (event) {
      if(keepOpen){
        tileModal.foundation("reveal", "open");
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
        }else{
          keepOpen = true;
        }
      }
    });

    //imagesModal
    $(document).on('closed.fndtn.reveal', imagesModalSelector, function () {
        tileModal.foundation("reveal", "open");
    });

    initJQueryObjects();
    initNewTileModal();
    initImageLibraryModal();
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

  function navigate(dir){
    event.preventDefault();
    grayoutTile();
    //loadNextTileWithOffsetForManagePreview(dir);
  }

  function attachRightAnswerMessage(event) {
    if (!checkInTile()) {
      return $(event.target).siblings('.answer_target').html("Correct!").slideDown(250);
    }
  }

  function init(){
    $('#spinner_large').css("display", "block");
    grayoutTile();
    //updateNavbarURL(data.tile_id);
    window.sharableTileLink();
    window.bindTagNameSearchAutocomplete('#add-tag', '#tag-autocomplete-target', "/client_admin/tile_tags");
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
