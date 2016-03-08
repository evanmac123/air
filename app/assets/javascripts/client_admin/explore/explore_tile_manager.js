var Airbo = window.Airbo || {};

Airbo.ExploreTileManager = (function(){
  function initEvents() {
    $("body").on("click", ".preview_link", function(e){
      e.preventDefault();
      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
        data: {partial_only: true},
        success: function(data, status,xhr){
          var tilePreview = Airbo.ExploreTilePreview;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }
  function initVars() {

  }
  function init() {
    initVars();
    initEvents();
  }
  return {
    init: init
  }
}());

$(function(){
  if( $(".tile_with_tags").length > 0 ) {
    Airbo.ExploreTileManager.init();
  }
});
