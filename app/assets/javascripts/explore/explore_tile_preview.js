var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var modalObj = Airbo.Utils.StandardModal();
  var modalId = "explore_tile_preview";
  var introShowed = false;
  var self;

  function ping(action) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    Airbo.Utils.ping('Explore page - Interaction', {action: action, tile_id: tile_id});
  }

  function initEvents() {
    Airbo.StickyMenu.init(self);
    Airbo.CopyTileToBoard.init();
    Airbo.ImageLoadingPlaceholder.init();

    $('.js-multiple-choice-answer.correct').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
      ping("Clicked Answer");
    });
  }

  function initPreviewElements() {
    Airbo.TilePreviewArrows.init();
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    initEvents();
    initAnonymousTooltip();

    //This handles issue where the onboarding modal css interferes with the tile modal css.
    $(".reveal-modal").css("top", 0);
  }

  function open(previewHTML) {
    modalObj.setContent(previewHTML);
    modalObj.open();
    initPreviewElements();
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

  function init() {
    self = this;
    initModalObj();
    return self;
  }

  return {
    init: init,
    open: open,
    modalId: modalId
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
  if( $(".single-tile-base, .explore-tile_previews-show").length > 0 ) {
    Airbo.ExploreTileNonModal.init();
  }
});
