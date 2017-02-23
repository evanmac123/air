var Airbo = window.Airbo || {};

Airbo.SearchTileThumbnailMenu = (function() {
  var tileCreator;

  function closeToolTips(){
    instances = $.tooltipster.instances();
    $.each(instances, function(i, instance){
      instance.close();
    });
  }

  function setMenuActiveState(origin, active) {
    if(active) {
      origin.addClass("active");
      origin.closest(".tile-wrapper").addClass("active_menu");
    } else {
      origin.removeClass("active");
      origin.closest(".tile-wrapper").removeClass("active_menu");
    }
  }

  function init(tile) {
    var menuButton = tile.find(".more_button");

    menuButton.tooltipster({
      theme: "tooltipster-shadow tooltipster-thumbnail-menu",
      interactive: true,
      position: "bottom",
      side:"top",
      trigger: "click",
      autoClose: true,

      functionInit: function(instance, helper){
        var content = $(helper.origin).find('.tooltip-content').detach();
        instance.content(content);
      },

      functionBefore: function(instance, helper){
        setMenuActiveState($(helper.origin), true);
      },

      functionAfter: function(instance, helper){
        setMenuActiveState($(helper.origin), false);
      },

      functionReady: function(instance, helper){
        $(".tile_thumbnail_menu .delete_tile, .tile_buttons .delete_tile").click(function(event){
          event.preventDefault();
          closeToolTips();
          Airbo.SearchTileActions.confirmDeletion($(this), tile, false);
        });

        $(".tile_thumbnail_menu .duplicate_tile").click(function(e){
          e.preventDefault();
          closeToolTips();
          Airbo.SearchTileActions.makeDuplication($(this), false);
        });
      }
    });
  }

  return {
    init: init
  };
}());
