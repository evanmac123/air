var Airbo = window.Airbo || {};

Airbo.TileThumbnail = (function() {
  var  thumbnailMenu
    , curTileContainerSelector
    , tileContainer = ".tile_container:not(.placeholder_container)"
    , buttons = tileContainer + " .tile_buttons a.button"
    , pills = tileContainer + " .tile_buttons a.pill"
    , thumbLinkSel = " .tile-wrapper a.tile_thumb_link"
  ;

  function initTileToolTipTip(){
    Airbo.TileThumbnailMenu.init();

 
  }

  function initActions(){
    $("body").on("click", ".tile_container .tile_buttons a", function(e){
      e.preventDefault();
      e.stopImmediatePropagation();
      var link = $(this);
      switch(link.data("action")){
        case "edit":
        handleEdit(link)
        break;

        case "post":
        case "archive":
        case "unarchive":
        case "ignore":
        case "unignore":
        handleUpdate(link)
        break;

        case "delete":
          handleDelete(link);
        break;


        case "accept":
          handleAccept(link)
        break;
      }
    });
  }

  function handleUpdate(link){
    Airbo.TileAction.updateStatus(link);
  }

  function handleAccept(link){ 
    Airbo.TileAction.confirmAcceptance(link);
  }

  function handleDelete(link){ 
    Airbo.TileAction.confirmDeletion(link);
  }

  function handleEdit(link){
    tileForm = Airbo.TileFormModal;
    tileForm.init(Airbo.TileManager);
    tileForm.open(link.attr("href"));
  }


  function getPreview(link, id, modalClass){
    var tile = tileContainerByDataTileId(id);
    var next = nextTile(tile).data('tileContainerId');
    var prev = prevTile(tile).data('tileContainerId');
    $.ajax({
      type: "GET",
      dataType: "html",
      data: { partial_only: true, from_search: true, next_tile: next, prev_tile: prev },
      url: link,
      success: function(data, status,xhr){
        var tilePreview = Airbo.TilePreviewModal;
        tilePreview.init(modalClass);
        tilePreview.open(data);
        //tilePreview.positionArrows();
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }



    //FIXME added from search tile thumbnail
  function nextTile(tile) {
    return Airbo.TileThumbnailManagerBase.nextTile(tile);
  }

  function prevTile(tile) {
    return Airbo.TileThumbnailManagerBase.prevTile(tile);
  }
  function tileContainerByDataTileId(id){
    return  $(".tile_container[data-tile-container-id=" + id + "]");
  }

  function initMyTilePreview(){
    $("body").on("click", ".tile_container .tile_thumb_link, .tile_container:not(.explore) .shadow_overlay", function(e){
      e.preventDefault();

      var self = $(this)
        , link
      ;

      if($(e.target).is(".pill.more") || $(e.target).is("span.dot")){
        return;
      }

      if((self).is(".tile_thumb_link")){
        link = self;
      }else{
        link = self.siblings(".tile_thumb_link");
      }

      getPreview(link.attr('href'), link.data('tileId'), "bg-user-side");
    });
  }

  function initExploreTilePreview(){

    $("body").on("click", ".tile_container.explore .tile_thumb_link_explore", function(e) {
      e.preventDefault();
      getPreview($(this).attr('href'), $(this).data('tileId'), "tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side");
    });
  }


  function initTiles(tileId) {
    initActions();
    initTileToolTipTip();
    //FIXME added from search tile thumbnail
    initExploreTilePreview();
    initMyTilePreview();
  }

  function initTile(){

  }

  function initEvents(){
    tileIds = $(".tile_container:not(.placeholder_container)").map(function(){
      return $(this).data("tile-container-id");
    });
    uniqueTileIds = jQuery.unique(tileIds);

    uniqueTileIds.each(function(){
      initTile( this );
    });
  }

  function init(AirboTileManager) {
    tileManager = AirboTileManager;
    initTiles();
    return this;
  }
  
  return {
    init: init,
    initTile: initTile,
    getPreview: getPreview
  }
}());
