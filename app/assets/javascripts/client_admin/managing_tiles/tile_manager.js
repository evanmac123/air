var Airbo = window.Airbo || {};

Airbo.TileManager = (function(){
  var newTileBtnSel = "#add_new_tile"
  ;
  var newTileBtn
    , thumbnailMenu
  ;
  function pageSectionByStatus(status){
    return $("#" + status + sectionSelector);
  }
  function replaceTileContent(tile, id){
    selector = tileWrapperSelector + "[data-tile-id=" + id + "]";
    $(selector).replaceWith(tile);
  }
  function findTile(tileId){
    return $(".tile_container[data-tile-id='"+tileId+"']");
  }
  function updateTileSection(data){
    var selector , section = pageSectionByStatus(data.tileStatus);
    if(findTile(data.tileId).length > 0){
      replaceTileContent(data.tile, data.tileId);
    } else{
      section.prepend(data.tile); //Add tile to section
      window.updateTilesAndPlaceholdersAppearance();
    }
    new_tile = findTile(data.tileId);
    thumbnailMenu.initMoreBtn(new_tile.find(".more_button"));
  }
  function initEvents() {
    newTileBtn.click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileFormModal);
      tileForm.open(url);
    });
  }
  function initVars() {
    newTileBtn = $(newTileBtnSel);
  }
  function init() {
    initVars();
    initEvents();
    if(Airbo.TileThumbnailMenu){
      thumbnailMenu = Airbo.TileThumbnailMenu.init(this);
    }
  }
  return {
    init: init,
    updateTileSection: updateTileSection
  }
}());

$(function(){
  Airbo.TileManager.init();
});
