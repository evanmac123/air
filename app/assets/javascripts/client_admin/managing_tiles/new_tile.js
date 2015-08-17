var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var newTileModal
    , imagesModal
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
          //$(imagesModalSelector).foundation("reveal", "open"); 
        },
        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      })
    });
  }

  function initImageLibraryModal(){
    $("body").on("click", addImageSelector, function(event){
      $(document).foundation({reveal: {multiple_opened: true}});
      $(imagesModalSelector).foundation("reveal", "open");
    });
  }

  function initJQueryObjects(){
    newTileModal = $(newTileModalSelector);
  }

  function init(){
    initJQueryObjects();
    initNewTileModal();
    $(document).foundation({reveal: {multiple_opened: true}});
    initImageLibraryModal();
  }

  return {

    init: init

  };

}());

$(function(){

Airbo.TileCreator.init();

})
