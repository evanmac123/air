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

  function getManagerType() {
    return managerType;
  }

  function pageSectionByStatus(status){
    return $("#" + status + sectionSelector);
  }

  function replaceTileContent(tile, id){
    selector = tileContainerByDataTileId(id);
    $(selector).replaceWith(tile);
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

  function updateSections(data) {
    updateTileSection(data);
    updateShowMoreDraftTilesButton();
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

  function init(type) {
    if(type==="search"){
      Airbo.SearchTileThumbnail.init();
    }
    else{
      Airbo.TileThumbnail.init();
    }

    initEvents();
  }
  return {
    init: init,
    updateTileSection: updateTileSection,
    updateSections: updateSections,
    getManagerType: getManagerType
  };
}());

$(function(){
  var manageType;
  var manageNum = $(".manage_tiles").length;
  if( manageNum > 0 ) {
    if(manageNum == 3) {
      manageType = "main";
    } else {
      manageType = "archived";
    }

    Airbo.TileManager.init();
  }

  if ( $(".has-tile-thumnails").length > 0 ) {
    Airbo.SearchTileManager.init();
  }
});
