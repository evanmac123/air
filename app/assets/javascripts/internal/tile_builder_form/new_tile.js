var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var tileModal
    , imagesModal
    , libaryLoaded
    , preventCloseMsg
    , keepOpen = false
    , newSelector = "a#add_new_tile, #add_new_tile.preview_menu_item a"
    , editSelector = ".tile_buttons .edit_button>a"
    , previewSelector = ".tile-wrapper a.tile_thumb_link"
    , tileModalSelector = "#new_tile_modal"
    , imagesModalSelector ="#images_modal"
    , addImageSelector ="#image_uploader"
    , tileForm ="#new_tile_builder_form"
    , modalActivationSelectors = [newSelector, editSelector, previewSelector].join(",")
  ;

 function prepEditOrNew(action){
   $(tileForm).data("asAjax", true);
   $("body").addClass("client_admin-tiles-edit");
   preventCloseMsg = action
 }

 function prepShow(){
   $("body").addClass("client_admin-tiles-show");
   preventClose = false
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



  function initNewTileModal(){

    $("body").on("click", modalActivationSelectors, function(event){
      event.preventDefault(); 
      var target = $(this);
      $.ajax({
        type: "GET",
        dataType: "html",
        url:target.attr("href") ,
        success: function(data, status,xhr){
          tileModal.find("#modal_content").html(data);
          processEvent(target);
          tileModal.foundation("reveal", "open");
          Airbo.TileImagesMgr.init();
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
    $(document).on('opened.fndtn.reveal',tileModalSelector, function () {
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

    $(document).on('closed.fndtn.reveal', tileModalSelector, function (event) {
      if(keepOpen){
        tileModal.foundation("reveal", "open");
      }
    })

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

$(function(){
Airbo.TileCreator.init();
})
