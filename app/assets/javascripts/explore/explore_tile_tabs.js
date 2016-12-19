var Airbo = window.Airbo || {};

Airbo.ExploreTileTabs = (function() {
  function initEvents() {
    $(".explore_tiles_tab").on("click", function(e) {
      e.preventDefault();
      var self = $(this);
      $(".explore_tiles_section").hide();
      $(self.data("content-selector")).show();
      $(".selected").removeClass("selected");
      self.addClass("selected");
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
  if( $(".tile_wall_explore").length > 0 ) {
    Airbo.ExploreTileTabs.init();
  }
});
