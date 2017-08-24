var Airbo = window.Airbo || {};

Airbo.TileManager = (function(){
  var newTileBtnSel = "#add_new_tile"
    , sectionSelector = ".manage_section"
    , tileWrapperSelector =".tile_container"
    , managerType // main or archived
  ;
  var newTileBtn,
  thumbnailMenu;

  // TODO Deprecate this method


  function pageSectionByStatus(status){
    return $("#" + status + sectionSelector);
  }


  function tileContainerByDataTileId(id){
    return  $(tileWrapperSelector + "[data-tile-container-id=" + id + "]");
  }

  function updateTileSection(data){
    var selector,
    section = pageSectionByStatus(data.tileStatus),
      tile = $(data.tile),
      img = tile.find(".tile_thumbnail_image>img")[0];

    $(img).css({height:"100%",width:"100%"});

    if (tileContainerByDataTileId(data.tileId).length > 0){
      replaceTileContent(tile, data.tileId);
    } else{
      section.prepend(tile); //Add tile to section
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
    }

    Airbo.TileThumbnailMenu.initMoreBtn(tile.find(".pill.more"));
  }

  function replaceTileContent(tile, id){
    if($(".explore-search-results-client_admin").length > 0){
      replaceTileContentSearch(tile, id);
    }else{
      replaceTileContentNormal(tile, id);
    }
  }

  function replaceTileContentNormal(tile, id){
    selector = tileContainerByDataTileId(id);
    $(selector).replaceWith(tile);
  }



  function replaceTileContentSearch(tile, id){
    selector = tileContainerByDataTileId(id);
    $(selector).each(function(idx, oldTile){
      var newTile = $(tile);
      $(oldTile).replaceWith(newTile);
      Airbo.TileThumbnailMenu.initMoreBtn(newTile.find(".pill.more"));
    });
  }


  function updateSectionsNormal(data){
    updateTileSection(data);
    updateShowMoreDraftTilesButton();
  }


  function updateSectionsSearch(data){
    var tile = data.tile;
    replaceTileContent(tile, data.tileId);
  }

  function updateSections(data) {

    if($(".explore-search-results-client_admin").length > 0){
      updateSectionsSearch(data);
    }else{
      updateSectionsNormal(data);
    }
  }

  function initEvents() {
    $(newTileBtnSel).click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });
  }

  function initVars(thumbNail) {
    tileThumbnail = thumbNail.init(this);
  }

  function initSearch() {
    var userType = $(".explore-search-results").data().userType;
    if (userType == "user") {
      Airbo.UserTileSearch.init();
    } else {
      Airbo.TileThumbnail.init();
      Airbo.TileStatsModal.init();
    }
  }

  function initNormal(){
    Airbo.TileThumbnail.init();
    initEvents();
  }

  function init() {

    if($(".explore-search-results-client_admin").length > 0){
      initSearch();
    }else{
      initNormal();
    }

    Airbo.TileAttachmentUploader.init();
    Airbo.TileImageUploader.init();
  }
  return {
    init: init,
    updateTileSection: updateTileSection,
    updateSections: updateSections,
    tileContainerByDataTileId: tileContainerByDataTileId
  };
}());

$(function(){
  if(  $(".manage_tiles").length > 0  || $(".explore-search-results-client_admin").length > 0) {
    Airbo.TileManager.init();
  }

});
