var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var modalObj = Airbo.Utils.StandardModal(),
      modalId = "explore_tile_preview",
      arrowsObj,
      introShowed = false,
      self;

  function ping(action) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    Airbo.Utils.ping('Explore page - Interaction', {action: action, tile_id: tile_id});
  }
  function tileContainerSizes() {
    tileContainer = $(".tile_full_image")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }
  function initEvents() {
    Airbo.StickyMenu.init(self);
    Airbo.CopyTileToBoard.init();

    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
      ping("Clicked Answer");
    });

    Airbo.ImageLoadingPlaceholder.init();
  }

  function open(preview) {
    modalObj.setContent(preview);
    modalObj.open();

    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    arrowsObj.initEvents();
    initEvents();
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side",
      useAjaxModal: true,
      closeSticky: true,
      onOpenedEvent: function() {
        arrowsObj.position();
      }
    });
  }
  function initFakeModalObj() {
    modalObj = Airbo.Utils.FakeModal();
    modalObj.init({
      containerSel: ".content",
      onOpenedEvent: function() {
        arrowsObj.position();
      }
    });
  }

  function init(fakeModal) {
    self = this;
    if(fakeModal) {
      initFakeModalObj();
    } else {
      initModalObj();
    }
    arrowsObj = Airbo.TilePreivewArrows();
    arrowsObj.init(this, {
      buttonSize: 40,
      offset: 20,
      afterNext: function() {
        ping("Clicked arrow to next tile");
      },
      afterPrev: function() {
        ping("Clicked arrow to previous tile");
      },
    });
    //move this to explore_tileManager!

    // initEvents();
    return self;
  }
  return {
    init: init,
    open: open,
    tileContainerSizes: tileContainerSizes,
    modalId: modalId
  };
}());

Airbo.GuestExploreTilePreview = (function(){
  function open() {

  }
  function init() {
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    Airbo.ImageLoadingPlaceholder.init();
    return this;
  }
  return {
    init: init,
    open: open
  };
}());

$(function(){
  if( $(".explore_menu").length > 0 ) {
    var preview = Airbo.ExploreTilePreview.init(true);
    preview.open();
  }
  if( $(".single_tile_guest_layout").length > 0 ) {
    Airbo.GuestExploreTilePreview.init();
  }
});
