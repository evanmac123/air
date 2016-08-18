var Airbo = window.Airbo || {};

Airbo.ExploreTileManager = (function(){
  function initEvents() {
    $("body").on("click", ".tile_thumb_link", function(e){
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
  };
}());

$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ExploreTileManager.init();
  }
});
