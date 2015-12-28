var Airbo = window.Airbo || {};

Airbo.TileThumbnailMenu = (function() {
  function htmlDecode(input){
    var e = document.createElement('div');
    e.innerHTML = input;
    return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
  }
  function init(tileCreator) {
    $(".tipsy.more_button").each(function(){
      var menu_button = $(this);
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
            tileCreator.confirmDeletion($(this));
          });
        }
      });
    });
  }
  return {
    init: init
  }

}());

// $(function(){
//   Airbo.TileThumbnailMenu.init();
// });
