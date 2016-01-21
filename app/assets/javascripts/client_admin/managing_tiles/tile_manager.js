var Airbo = window.Airbo || {};

Airbo.TileManager = (function(){
  var newTileBtnSel = "#add_new_tile"
    , sectionSelector = ".manage_section"
    // , editTileBtnSel = ".edit_button a"
    // , openFormSel = [newTileBtnSel, editTileBtnSel].join(", ")
    , tileWrapperSelector =".tile_container"
  ;
  var newTileBtn
    , thumbnailMenu
  ;
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
    var selector , section = pageSectionByStatus(data.tileStatus);
    if(tileContainerByDataTileId(data.tileId).length > 0){
      replaceTileContent(data.tile, data.tileId);
    } else{
      section.prepend(data.tile); //Add tile to section
      window.updateTilesAndPlaceholdersAppearance();
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
  function init() {
    initVars();
    initEvents();
  }
  return {
    init: init,
    updateTileSection: updateTileSection,
    updateSections: updateSections
  }
}());

$(function(){
  if( $(".manage_tiles").length > 0 ) {
    Airbo.TileManager.init();
  }
});
