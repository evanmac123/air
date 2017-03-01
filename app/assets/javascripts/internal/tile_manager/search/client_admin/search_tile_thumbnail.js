var Airbo = window.Airbo || {};

Airbo.SearchTileThumbnail = (function() {
  var tileManager,
      thumbnailMenu,
      thumbLinkSel = "a.tile_thumb_link_client_admin";

  function initTileToolTip(){
   Airbo.SearchTileThumbnailMenu.init();
  }

  function initActions(){
    $("body").on("click", ".tile_container .tile_buttons a", function(e){
      e.preventDefault();
      e.stopImmediatePropagation();
      var link = $(this);
      switch(link.data("action")){
        case "edit":
          handleEdit(link);
        break;

        case "post":
        case "archive":
        case "unarchive":
        case "ignore":
        case "unignore":
          handleUpdate(link);
        break;

        case "delete":
          handleDelete(link);
        break;


        case "accept":
          handleAccept(link);
        break;
      }
    });
  }

  function handleUpdate(link){
    Airbo.SearchTileActions.updateStatus(link);
  }

  function handleAccept(link){
    Airbo.SearchTileActions.confirmAcceptance(link);
  }

  function handleDelete(link){
    Airbo.SearchTileActions.confirmDeletion(link);
  }

  function handleEdit(link){
    tileForm = Airbo.TileFormModal;
    tileForm.init(Airbo.SearchTileManager);
    tileForm.open(link.attr("href"));
  }

  function getPreview(url){
    $.ajax({
      type: "GET",
      dataType: "html",
      data: { from_search: true },
      url: url ,
      success: function(data, status,xhr){
        var tilePreview = Airbo.SearchTilePreviewModal;
        tilePreview.init();
        tilePreview.open(data);
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function initPreview() {
    initExploreTilePreview();
    initMyTilePreview();
  }


  function initMyTilePreview(){
    $("body").on("click", ".tile_container:not(.explore) .shadow_overlay", function(e){
      e.preventDefault();

      if($(e.target).is(".pill.more") || $(e.target).is("span.dot")){
        return;
      }
      var link = $(this).siblings(".tile_thumb_link");
      getPreview(link.attr("href"));

    });
  }

  function initExploreTilePreview(){
    $("body").on("click", ".tile_container.explore .tile_thumb_link_explore", function(e){
      e.preventDefault();
      getPreview($(this).attr("href"));
    });
  }


  function init(AirboTileManager) {
    initPreview();
    initActions();
    initTileToolTip();
  }

  return {
    init: init,
  };
}());
