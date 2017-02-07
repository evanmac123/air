var Airbo = window.Airbo || {};

Airbo.ClientAdminTilePreviewModal = (function(){
  var modalId = "tile_preview_modal",
      self,
      modalObj = Airbo.Utils.StandardModal(),
      arrowsObj,
      tileManager;

  function tileContainerSizes() {
    tileContainer = $(".tile_full_image")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }
  function initSharing(){
    Airbo.TileSharingMgr.init();
    Airbo.TileTagger.init({
      submitSuccess:  function(data){
        // no need to update tags
      }
    });
  }
  function prepareToolTip(origin, content){
    initSharing();
    initStatusUpdate();
  }

  function initPreviewMenuTooltips(){
    $(".tipsy:not(.disabled)").tooltipster({
      theme: "tooltipster-shadow",
      interactive: true,
      position: "bottom",
      contentAsHTML: true,
      functionReady: prepareToolTip,
      trigger: "click"
    });
  }

  function initDisabled(){
    $(".tipsy.disabled").click(function(){
      Airbo.Utils.alert(Airbo.Utils.Messages.incompleteTile);
    });
  }


  function initStickyPreviewMenu() {
    Airbo.StickyMenu.init(self);
  }

  function initEvents() {
    $(".preview_menu_item.edit a").click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });

    $(".preview_menu_item .delete_tile").click(function(event){
      event.preventDefault();
      Airbo.TileAction.confirmDeletion($(this));
    });

    $(".preview_menu_item .duplicate_tile").click(function(event){
      event.preventDefault();
      Airbo.ClientAdminTileActions.makeDuplication($(this));
    });


    $(".preview_menu_item .accept").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.TileAction.confirmAcceptance(target);
    });

    initDisabled();
  }


  function initStatusUpdate(){
    $(".preview_menu_item .update_status").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.ClientAdminTileActions.updateStatus(target);
    });
  }

  function initPreviewElements() {
    Airbo.TileCarouselPage.init();
    initPreviewMenuTooltips();
    Airbo.ImageLoadingPlaceholder.init();
    initStickyPreviewMenu();
    arrowsObj.initEvents();
    initEvents();
  }
  function open(preview) {
    modalObj.setContent(preview);
    initPreviewElements();
    modalObj.open();
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      modalClass: "bg-user-side",
      closeSticky: true,
      onOpenedEvent: function() {
        arrowsObj.position();
      },
      onClosedEvent: function() {
        $(".tipsy").tooltipster("hide");
      }
    });
  }
  function init(AirboTileManager){
    self = this;
    arrowsObj = Airbo.TilePreivewArrows();
    initModalObj();
    arrowsObj.init(self, {buttonSize: 40, offset: 20});
    tileManager = AirboTileManager;
    return this;
  }
  return {
    init: init,
    open: open,
    close: close,
    tileContainerSizes: tileContainerSizes,
    modalId: modalId
  };
}());
