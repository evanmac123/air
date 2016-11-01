var Airbo = window.Airbo || {};

Airbo.ShowMoreTiles = (function() {
  function initEvents(currentPage, spinnerSelector, downArrowSelector, updateMethod) {
    $(".explore_show_more_tiles").on("click", function(e) {
      e.preventDefault();
      currentPage += 1;

      var self = $(this);
      var tilePath = self.data("tile-path");
      var tileType = self.data("tile-type");
      var offset = self.data("tile-count");
      var contentType = self.data('contentType');
      var targetSelector = self.data('target-selector');

      if (self.attr('disabled') == 'disabled') { return; }

      $(downArrowSelector).hide();
      $(spinnerSelector).show();

      $.get(tilePath, { offset: offset, partial_only: 'true', page: currentPage, tile_type: tileType }, (function(data) {
        var content = data.htmlContent || data;
        $(spinnerSelector).hide();
        $(downArrowSelector).show();
        switch (updateMethod) {
          case 'append':
            $(targetSelector).append(content);
          break;
          case 'replace':
            $(targetSelector).replaceWith(content);
        }

        if (data.lastBatch) {
          $(self).attr('disabled', 'disabled');
        }

      }), contentType);
    });
  }

  function init() {
    var currentPage = 1;
    var spinnerSelector = '.show_more_tiles_spinner';
    var downArrowSelector = '.show_more_tiles_copy';
    var updateMethod = 'append';
    initEvents(currentPage, spinnerSelector, downArrowSelector, updateMethod);
  }

  return {
    init: init
  };

}());

$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.ShowMoreTiles.init();
  }
});
