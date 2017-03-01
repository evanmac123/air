var Airbo = window.Airbo || {};

Airbo.TilePreivewArrows = (function(){
  return function(){
    var clientAdmintileNavLeft = ".tile_preview_container .viewer  #prev",
    clientAdmintileNavRight = ".tile_preview_container .viewer #next",
    exploreTileNavLeft = ".button_arrow.prev_tile",
    exploreTileNavRight = ".button_arrow.next_tile",
    tileNavRight = [clientAdmintileNavRight, exploreTileNavRight].join(", "),
    tileNavLeft = [clientAdmintileNavLeft, exploreTileNavLeft].join(", "),
    tileNavSelector = [tileNavRight, tileNavLeft].join(", "),
    exploreNav = [exploreTileNavLeft, exploreTileNavRight].join(", "),
    clientAdminNav = [clientAdmintileNavLeft, clientAdmintileNavRight].join(", "),
    tilePreview,
    defaultParams = {
      buttonSize: 100,
      offset: 10,
      afterNext: Airbo.Utils.noop,
      afterPrev: Airbo.Utils.noop,
    },
    params;

    function position() {
      sizes = tilePreview.tileContainerSizes();
      if (!sizes || sizes.left === 0 && sizes.right === 0) return;

      $(tileNavLeft).css("left", sizes.left - params.buttonSize - params.offset);
      $(tileNavRight).css("left", sizes.right + params.offset);
      $(tileNavSelector).css("display", "block");
    }

    function initEvents() {
      $(clientAdminNav).click(function(e){
        e.preventDefault();
        if( $(this)[0] == $(tileNavLeft)[0] ) {
          params.afterPrev();
        } else if( $(this)[0] == $(tileNavRight)[0] ) {
          params.afterNext();
        }
        var link = $(this);
        $.ajax({
          type: "GET",
          dataType: "html",
          url: link.attr("href"),
          data: { partial_only: true },
          success: function(data, status, xhr) {
            tilePreview.open(data);
            position();
          },

          error: function(jqXHR, textStatus, error){
            console.log(error);
          }
        });
      });

      $(exploreNav).click(function(e) {
        e.preventDefault();
        var id = $(this).data('tileId');
        var path = $(this).attr('href');

        Airbo.ExploreTileManager.getExploreTile(path, id);
      });
    }

    function init(AirboTilePreview, userParams) {
      tilePreview = AirboTilePreview;
      params = $.extend(defaultParams, userParams);
    }

    return {
      init: init,
      initEvents: initEvents,
      position: position
    };
  };
}());
