var Airbo = window.Airbo || {};

Airbo.ShareLink = (function(){
  function pingShareTile(action) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    Airbo.Utils.ping('Explore page - Interaction', {action: action, tile_id: tile_id});
  };
  function initEvents(){
    $("#share_link").on('click', function(event) {
      event.preventDefault();
      return $(event.target).focus().select();
    });
    $("#share_link").on('keydown keyup keypress', function(event) {
      if (!(event.ctrlKey || event.altKey || event.metaKey)) {
        return event.preventDefault();
      }
    });
    $("#share_link").bind({
      copy: function() {
        return pingShareTile("Copied tile link");
      },
      cut: function() {
        return pingShareTile("Copied tile link");
      }
    });
  }
  function init() {
    initEvents();
  }
  return {
    init: init
  }
}());