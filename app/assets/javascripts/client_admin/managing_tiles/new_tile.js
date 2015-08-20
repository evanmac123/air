var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var newTileModal
    , imagesModal
    , libaryLoaded
    , newTileSelector = "#add_new_tile.preview_menu_item a"
    , newTileModalSelector = "#new_tile_modal"
    , imagesModalSelector ="#images_modal"
    , addImageSelector ="#image_uploader"
  ;

  function initNewTileModal(){

    $("body").on("click", newTileSelector, function(event){
      event.preventDefault(); 
      $.ajax({
        type: "GET",
        dataType: "html",
        url:$(this).attr("href") ,
        success: function(data, status,xhr){
          newTileModal.html(data);
          newTileModal.foundation("reveal", "open");
        },
        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      })
    });
  }

  function getImageLibrary(libaryUrl){

      $.ajax({
        type: "GET",
        dataType: "html",
        url: libaryUrl,
        success: function(data, status,xhr){
          imagesModal.html(data);
          Airbo.ImageLibrary.init();
          $(imagesModalSelector).foundation("reveal", "open");
          libaryLoaded = true;
        },
        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      })
  }

  function initImageLibraryModal(){
    $("body").on("click", addImageSelector, function(event){
      if(libaryLoaded){
        $(imagesModalSelector).foundation("reveal", "open");
      }else{
        getImageLibrary($(this).data("libraryUrl"));
      }
    });
  }

  function initJQueryObjects(){
    newTileModal = $(newTileModalSelector);
    imagesModal = $(imagesModalSelector);
  }

  function init(){
    $(document).on('opened.fndtn.reveal',imagesModalSelector, function () {
    });

    $(document).on('closed.fndtn.reveal', imagesModalSelector, function () {
      newTileModal.foundation("reveal", "open");
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
