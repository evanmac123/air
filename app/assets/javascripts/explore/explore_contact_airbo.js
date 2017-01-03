var Airbo = window.Airbo || {};

Airbo.ExploreContactAirbo = (function(){
  function init() {
    $("#contact-airbo").on("click", function(e) {
      e.preventDefault();
      bindIntercomOpen("#contact-airbo");
      Airbo.Utils.ping('Explore page - Interaction', { action: 'Clicked Contact Airbo button' } );
    });
  }

  return {
    init: init,
  };
}());

$(function(){
  if( $(".tile_wall_explore").length > 0 ) {
    Airbo.ExploreContactAirbo.init();
  }
});
