var Airbo = window.Airbo || {};

Airbo.SearchTileThumbnail = (function() {
  var tileManager,
      thumbnailMenu,
      thumbLinkSel = "a.tile_thumb_link_client_admin";

  function initTileToolTipTip(){
   Airbo.SearchTileThumbnailMenu.init();
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


  function initPreview() {
    $("body").on("click", ".tile_container .tile_thumb_link, .tile_container .shadow_overlay", function(e){
      var self = $(this)
        ,   link
      ;

      e.preventDefault();

      //return immediately if tooltipser is triggered since we want to let it  
      //do its own handling and not do the preview
      if($(e.target).is("a.button") || $(e.target).is(".pill.more") || $(e.target).is("span.dot")){
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
          var tilePreview = Airbo.SearchTilePreviewModal;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }


  function init(AirboTileManager) {

    initPreview()
    initActions();
    initTileToolTipTip();
  }

  return {
    init: init,
  };
}());
