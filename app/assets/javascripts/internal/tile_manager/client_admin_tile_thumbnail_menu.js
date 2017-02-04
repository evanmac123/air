var Airbo = window.Airbo || {};

Airbo.ClientAdminTileThumbnailMenu = (function() {
  var tileCreator;

  function setMenuActiveState(origin, active) {
    if(active) {
      origin.addClass("active");
      origin.closest(".tile-wrapper").addClass("active_menu");
    } else {
      origin.removeClass("active");
      origin.closest(".tile-wrapper").removeClass("active_menu");
    }
  }

  function init(tile){
    var menuButton = tile.find(".more_button");

    menuButton.tooltipster({
      theme: "tooltipster-shadow tooltipster-thumbnail-menu",
      interactive: true,
      position: "bottom",
      content: function(){
        encodedMenu = menuButton.data('title');
        decodedMenu = Airbo.Utils.htmlDecode(encodedMenu);
        return $(decodedMenu);
      },
      trigger: "click",
      autoClose: true,
      functionBefore: function(origin, continueTooltip){
        setMenuActiveState(origin, true);
        continueTooltip();
      },
      functionAfter: function(origin){
        setMenuActiveState(origin, false);
      },
      functionReady: function(origin, tooltip){
        $(".tile_thumbnail_menu .delete_tile, .tile_buttons .delete_tile").click(function(event){
          event.preventDefault();
          origin.tooltipster("hide");
          Airbo.ClientAdminTileActions.confirmDeletion($(this), tile, false);
        });

        $(".tile_thumbnail_menu .duplicate_tile").click(function(e){
          e.preventDefault();
          origin.tooltipster("hide");
          Airbo.ClientAdminTileActions.makeDuplication($(this), false);
        });
      }
    });
  }

  return {
    init: init
  };
}());
