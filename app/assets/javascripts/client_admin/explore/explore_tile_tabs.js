var Airbo = window.Airbo || {};

Airbo.ExploreTileTabs = (function() {
  function initEvents() {
    $(".explore_tiles_tab").on("click", function(e) {
      e.preventDefault();
      var self = $(this);

      if (!self.hasClass("selected")) {
        $(".explore_tiles_section").toggle();
        self.addClass("selected");
        $(".selected").removeClass("selected");
      }
    });
  }

  function init() {
    initEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ExploreTileTabs.init();
  }
});
