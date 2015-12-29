var Airbo = window.Airbo || {};

Airbo.TileThumbnailMenu = (function() {
  var tileCreator;

  function htmlDecode(input){
    var e = document.createElement('div');
    e.innerHTML = input;
    return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
  }
  function initMoreBtn(menu_button){
    menu_button.tooltipster({
      theme: "tooltipster-shadow",
      interactive: true,
      position: "bottom",
      content: function(){
        encodedMenu = menu_button.data('title');
        decodedMenu = htmlDecode(encodedMenu);
        return $(decodedMenu);
      },
      trigger: "click",
      autoClose: true,
      functionReady: function(){
        $(".tile_thumbnail_menu .delete_tile").click(function(event){
          event.preventDefault();
          $(".more_button").tooltipster("hide");
          tileCreator.confirmDeletion($(this));
        });

        $(".tile_thumbnail_menu .duplicate_tile").click(function(event){
          event.preventDefault();
          $(".more_button").tooltipster("hide");
          $.ajax({
            type: "POST",
            dataType: "json",
            url: $(this).attr("href") ,
            success: function(data, status,xhr){
              tileCreator.updateTileSection(data);
              new_tile = $(".tile_container[data-tile-id='"+data.tileId+"']");
              initMoreBtn(new_tile.find(".more_button"));
            },

            error: function(jqXHR, textStatus, error){
              console.log(error);
            }
          });
        });
      }
    });
  }
  function init(AirboTileCreator) {
    tileCreator = AirboTileCreator;

    $(".more_button").each(function(){
      initMoreBtn($(this));
    });
  }
  return {
    init: init
  }

}());

// $(function(){
//   Airbo.TileThumbnailMenu.init();
// });
