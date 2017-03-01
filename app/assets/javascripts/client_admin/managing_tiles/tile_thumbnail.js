var Airbo = window.Airbo || {};

Airbo.TileThumbnail = (function() {
  var tileManager
    , thumbnailMenu
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

  function initPreview(){
    $("body").on("click", ".tile_container .tile_thumb_link, .tile_container .shadow_overlay", function(e){
      var self = $(this)
        ,   link
      ;

      e.preventDefault();


      //return immediately if tooltipser is triggered since we want to let it  
      //do its own handling and not do the preview
      if($(e.target).is(".pill.more") || $(e.target).is("span.dot")){
        return;
      }

      if((self).is(".tile_thumb_link")){
        link = self;
      }else{
        link = self.siblings(".tile_thumb_link");
      }

      $.ajax({
        type: "GET",
        dataType: "html",
        url: link.attr("href") ,
        success: function(data, status,xhr){
          var tilePreview = Airbo.TilePreviewModal;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }

  function initTiles(tileId) {
    initPreview()
    initActions();
    initTileToolTipTip();
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
    initTile: initTile
  }
}());
