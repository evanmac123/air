var Airbo = window.Airbo || {};

Airbo.TileManager = (function(){
  var newTileBtnSel = "#add_new_tile"
    , sectionSelector = ".manage_section"
    // , editTileBtnSel = ".edit_button a"
    // , openFormSel = [newTileBtnSel, editTileBtnSel].join(", ")
    , tileWrapperSelector =".tile_container"
    , managerType // main or archived
  ;
  var newTileBtn
    , thumbnailMenu
  ;
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
    var selector
      , section = pageSectionByStatus(data.tileStatus)
      , tile = $(data.tile)
      img = tile.find(".tile_thumbnail_image>img")[0];

      $(img).css({height:"100%",width:"100%"});

    if(tileContainerByDataTileId(data.tileId).length > 0){
      replaceTileContent(tile, data.tileId);
    } else{
      section.prepend(tile); //Add tile to section
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
    }
    tileThumbnail.initTile(data.tileId);
    // new_tile = tileContainerByDataTileId(data.tileId);
    // thumbnailMenu.initMoreBtn(new_tile.find(".more_button"));
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
  function initVars() {
    tileThumbnail = Airbo.TileThumbnail.init(this);
  }
  function init(type) {
    managerType = type;
    initVars();
    initEvents();
  }
  return {
    init: init,
    updateTileSection: updateTileSection,
    updateSections: updateSections,
    getManagerType: getManagerType
  }
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
    Airbo.TileManager.init(manageType);
  }
});
