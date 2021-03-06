var Airbo = window.Airbo || {};

Airbo.TilePreviewModal = (function() {
  var modalObj = Airbo.Utils.StandardModal();
  var modalId = "tile_preview_modal";
  var self;

  function initDisabled() {
    $(".tipsy.disabled").click(function() {
      Airbo.Utils.alert(Airbo.Utils.Messages.incompleteTile);
    });
  }

  function initStickyPreviewMenu() {
    Airbo.StickyMenu.init(self);
  }

  function initTileToolbarActions() {
    // FIXME
    // there are same events in Airbo.TileThumbnail (edit, update, delete, duplicate)
    // reason: i want to have object, its elements and its events in one place
    $(".preview_menu_item.edit a").click(function(e) {
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;

      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });

    $(".preview_menu_item .delete_tile").click(function(event) {
      event.preventDefault();
      Airbo.TileAction.confirmDeletion($(this));
    });

    $(".preview_menu_item .duplicate_tile").click(function(event) {
      event.preventDefault();
      Airbo.TileAction.makeDuplication($(this));
    });

    initDisabled();

    if ($(".js-suggested-tile-preview").length > 0) {
      initStatusUpdate();
    }
  }

  function initStatusUpdate() {
    $(".preview_menu_item .update_status").click(function(e) {
      e.preventDefault();
      e.stopPropagation();
      Airbo.TileAction.updateStatus($(this));
    });
  }

  function initAnonymousTooltip() {
    $(".js-anonymous-tile-tooltip").tooltipster({
      theme: "tooltipster-shadow"
    });
  }

  function initPreviewElements() {
    Airbo.TilePreviewArrows.init();
    Airbo.TileCarouselPage.init();
    initAnonymousTooltip();
    Airbo.ImageLoadingPlaceholder.init();
    initStickyPreviewMenu();
    initTileToolbarActions();
    Airbo.UserTileShareOptions.init();
  }

  function open(previewHTML) {
    modalObj.setContent(previewHTML);
    modalObj.open();
    initPreviewElements();
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      modalClass: "bg-user-side",
      closeSticky: true,
      onClosedEvent: function() {
        $(".tipsy").tooltipster("hide");
      }
    });
  }
  function init(AirboTileManager) {
    self = this;
    initModalObj();
    tileManager = AirboTileManager;
    return this;
  }
  return {
    init: init,
    open: open,
    close: close,
    modalId: modalId
  };
})();
