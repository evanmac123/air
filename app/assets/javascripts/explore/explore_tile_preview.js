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
    Airbo.ImageLoadingPlaceholder.init();
    arrowsObj.initEvents();

    $('.js-multiple-choice-answer.correct').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
      ping("Clicked Answer");
    });
  }

  function open(preview) {
    modalObj.setContent(preview);
    modalObj.open();

    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    initEvents();

    initAnonymousTooltip();

    //This handles issue where the onboarding modal css interferes with the tile modal css.
    $(".reveal-modal").css("top", 0);
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side",
      useAjaxModal: true,
      closeSticky: true
    });
  }

  function initAnonymousTooltip(){
    $(".js-anonymous-tile-tooltip").tooltipster({
      theme: "tooltipster-shadow" 
    });
  }

  function positionArrows() {
    arrowsObj.position();
  }

  function init() {
    self = this;
    initModalObj();
    arrowsObj = Airbo.TilePreivewArrows();
    arrowsObj.init(this, { buttonSize: 40, offset: 20 });
    return self;
  }

  return {
    init: init,
    open: open,
    tileContainerSizes: tileContainerSizes,
    modalId: modalId,
    positionArrows: positionArrows
  };
}());

Airbo.ExploreTileNonModal = (function(){
  function init() {
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    Airbo.ImageLoadingPlaceholder.init();
    return this;
  }
  return {
    init: init
  };
}());

$(function(){
  if( $(".single_tile_explore_layout, .explore-tile_previews-show").length > 0 ) {
    Airbo.ExploreTileNonModal.init();
  }
});
