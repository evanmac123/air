var Airbo = window.Airbo || {};

Airbo.ShareLink = (function(){
  function pingShareTile(action) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    return $.post("/ping", {
      event: 'Explore page - Interaction',
      properties: {
        action: action,
        tile_id: tile_id
      }
    });
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
    $(".share_linkedin").click(function(e) {
      var url;
      e.preventDefault();
      url = $(".share_linkedin a").attr("href");
      window.open(url, '', 'width=620, height=500');
      return pingShareTile("Clicked share tile via LinkedIn");
    });
    $(".share_mail").click(function() {
      return pingShareTile("Clicked share tile via email");
    });
  }
  function init() {
    initEvents();
  }
  return {
    init: init
  }
}());