var Airbo = window.Airbo || {};

Airbo.TilePreviewModal = (function(){
  var modalId = "tile_preview_modal"
  , tileNavigationSelectorLeft = ".tile_preview_container .viewer  #prev"
  , tileNavigationSelectorRight = ".tile_preview_container .viewer #next"
  , dummyTileNavigationSelectorLeft = ".preview_placeholder #prev"
  , dummyTileNavigationSelectorRight = ".preview_placeholder #next"
  , tileNavigationSelector = tileNavigationSelectorLeft + ', ' + tileNavigationSelectorRight
  , tileNavLeft = tileNavigationSelectorLeft + ', ' + dummyTileNavigationSelectorLeft
  , tileNavRight = tileNavigationSelectorRight + ', ' + dummyTileNavigationSelectorRight
  , tileNavSelectors = tileNavLeft + ', ' + tileNavRight
  ;
  var modalObj = Airbo.Utils.StandardModal()
    , tileManager
  ;
  function tileContainerSizes() {
    tileContainer = $(".tile_full_image")[0]  || $(".pholder.image")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }
  function positionArrows() {
    sizes = tileContainerSizes();
    if (!sizes || sizes.left == 0 && sizes.right == 0) return;

    $(tileNavLeft).css("left", sizes.left - 65);
    $(tileNavRight).css("left", sizes.right);
    $(tileNavSelectors).css("display", "block");
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
  }
  function initPreviewMenuTooltips(){
    $(".tipsy").tooltipster({
      theme: "tooltipster-shadow",
      interactive: true,
      position: "bottom",
      contentAsHTML: true,
      functionReady: prepareToolTip,
      trigger: "click"
    });
  }
  function initImgLoadingPlaceHolder(){
    $("#tile_img_preview").on("load", function(){
      $(".tile_full_image").removeClass("loading").attr("style", "");
    });
  }
  function initStickyPreviewMenu() {
    var modal = $("#" + modalId);
    var previewMenu = $('.tile_preview_menu');
    modal.scroll(function() {
      if (modal.scrollTop() > 50) {
        sizes = tileContainerSizes();
        previewMenu.addClass('sticky').css("left", sizes.left);
      } else {
        previewMenu.removeClass('sticky').css("left", "");
      }
    });
  }
  function initEvents() {
    $(tileNavigationSelector).click(function(e){
      e.preventDefault();

      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
        success: function(data, status,xhr){
          // var tilePreview = Airbo.TilePreviewModal;
          // tilePreview.init();
          open(data);
          positionArrows();
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
    // FIXME
    // there are same events in Airbo.TileThumbnail (edit, update, delete, duplicate)
    // reason: i want to have object, its elements and its events in one place
    $(".preview_menu_item.edit a").click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });

    $(".preview_menu_item .update_status").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.TileAction.updateStatus(target);
    });

    $(".preview_menu_item .delete_tile").click(function(event){
      event.preventDefault();
      Airbo.TileAction.confirmDeletion($(this));
    });

    $(".preview_menu_item .duplicate_tile").click(function(event){
      event.preventDefault();
      Airbo.TileAction.makeDuplication($(this));
    });
  }
  function initPreviewElements() {
    Airbo.TileCarouselPage.init();
    initPreviewMenuTooltips();
    initImgLoadingPlaceHolder();
    initStickyPreviewMenu();
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
      onOpenedEvent: function() {
        positionArrows();
      }
    });
  }
  function init(AirboTileManager){
    initModalObj();
    tileManager = AirboTileManager;
  }
  return {
    init: init,
    open: open
  }
}());
