replaceMovedTile = function(tile_id, updated_tile_container){
  tile = $("#single-tile-" + tile_id).closest(".tile_container");
  tile.replaceWith(updated_tile_container);
  tile = $("#single-tile-" + tile_id).closest(".tile_container");
  Airbo.TileThumbnailMenu.initMoreBtn(tile.find(".more_button"));
}

updateShareTilesNumber = function(number){
  $("#share_tiles span").text(number);
}

updateShowMoreDraftTilesButton = function(){
  button = $(".show_all_draft_section")
  if( showMoreDraftTiles() || showMoreSuggestionBox() ){
    button.show();
  }else{
    button.hide();
  }
}

updateShowMoreArchiveTilesButton = function(){
  if( Airbo.TileManager.managerType == "archived" ) {
    return;
  }

  button = $(".show_all_inactive_section")
  if( notTilePlaceholdersInSection( $("#archive") ).length > 4 ){
    button.show()
  }else{
    button.hide()
  }
}

updateShowMoreButtons = function(){
  updateShowMoreDraftTilesButton();
  updateShowMoreArchiveTilesButton();
}

showMoreDraftTiles = function(){
  draftTilesCount = notTilePlaceholdersInSection( $("#draft") ).length
  return (draftTilesCount > 6 && selectedSection() == 'draft')
}

showMoreSuggestionBox = function(){
  suggestionBoxTilesCount = notTilePlaceholdersInSection( $("#suggestion_box") ).length
  return (suggestionBoxTilesCount > 6 && selectedSection() == 'box')
}

selectedSection = function() {
  if( $("#draft_tiles.draft_selected").length > 0 ){
    return 'draft';
  } else {
    return 'box';
  }
}

fillInLastTile = function(tile_id, section_name, tile_container){
  section = $("#" + section_name)
  if( sectionHasFreePlace(section) && tileIsNotPresent(tile_id) ){
    addTileOnFreePlace(section, tile_container)
  }
}

addTileOnFreePlace = function(section, tile_container){
  free_place = freePlaceForTile(section)
  free_place.removeClass("placeholder_container").replaceWith(tile_container)
}

freePlaceForTile = function(section){
  free_place = $( tilePlaceholdersInSection(section)[0] )
  if(free_place.length == 0){
    free_place = $('<div class="tile_container"></div>')
    section.append(free_place)
  }
  return free_place
}

tileIsNotPresent = function(tile_id){
  return !tileIsPresent(tile_id)
}

tileIsPresent = function(tile_id){
  return ($("#single-tile-" + tile_id).length > 0)
}

sectionHasFreePlace = function(section){
  return !sectionIsFull(section)
}

sectionIsFull = function(section){
  var tileNum = Airbo.Utils.TilePlaceHolderManager.visibleTilesNumberIn(section);
  return (notTilePlaceholdersInSection(section).length >= tileNum);
}

notTilePlaceholdersInSection = function(section){
  return section.children( notTilePlaceholderSelector() )
}

tilePlaceholdersInSection = function(section){
  return section.children( tilePlaceholderSelector() )
}

notTilePlaceholderSelector = function(){
  return ".tile_container:not(.placeholder_container)"
}

tilePlaceholderSelector = function(){
  return ".tile_container.placeholder_container"
}
