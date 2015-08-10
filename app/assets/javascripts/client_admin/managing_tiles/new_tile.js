var Airbo = window.Airbo || {};

Airbo.TileCreator = (function(){
  var newTile;

  function initNewTileLink(){

    $("body").on("click", newTile, function(event){
      event.preventDefault(); 

      $.ajax({
        type: "GET",
        dataType: "html",
        url:$(this).attr("href") ,
        success: function(data, status,xhr){
          debugger
          console.log(data);
        },
        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });

  }

  function initSelectors(){

    newTile =$("#add_new_tile_link");
  }

  function init(){
    initSelectors();
    initNewTileLink();
  }

  return {

    init: init

  };

}());

$(function(){

Airbo.TileCreator.init();

})
