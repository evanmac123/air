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
      theme: "tooltipster-shadow tooltipster-thumbnail-menu",
      interactive: true,
      position: "bottom",
      content: function(){
        encodedMenu = menu_button.data('title');
        decodedMenu = htmlDecode(encodedMenu);
        return $(decodedMenu);
      },
      trigger: "click",
      autoClose: true,
      functionBefore: function(origin, continueTooltip){
        origin.addClass("active");
        origin.closest(".tile-wrapper").addClass("active_menu");
        continueTooltip();
      },
      functionAfter: function(origin){
        origin.removeClass("active");
        origin.closest(".tile-wrapper").removeClass("active_menu");
      },
      functionReady: function(origin, tooltip){
        $(".tile_thumbnail_menu .delete_tile").click(function(event){
          event.preventDefault();
          origin.tooltipster("hide");
          tileCreator.confirmDeletion($(this));
        });

        $(".tile_thumbnail_menu .duplicate_tile").click(function(event){
          event.preventDefault();
          origin.tooltipster("hide");
          tileCreator.makeDuplication($(this));
        });
      }
    });
  }
  function init(AirboTileCreator) {
    tileCreator = AirboTileCreator;

    $(".more_button").each(function(){
      initMoreBtn($(this));
    });
    return this;
  }
  return {
    init: init,
    initMoreBtn: initMoreBtn
  }

}());
