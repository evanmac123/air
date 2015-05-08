replaceMovedTile = function(tile_id, updated_tile_container){
  $("#single-tile-" + tile_id).closest(".tile_container").replaceWith(updated_tile_container)
}

updateShareTilesNumber = function(number){
  $("#share_tiles span").text(number);
}

updateShowMoreDraftTilesButton = function(show){
  button = $(".all_draft")
  if(show == "true"){
    button.show()
  }else{
    button.hide()
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
  return (notTilePlaceholdersInSection(section).length >= 8)
}

notTilePlaceholdersInSection = function(section){
  return section.children( notTilePlaceholderSelector() )
}

tilePlaceholdersInSection = function(section){
  return section.children( tilePlaceholderSelector() )
}

notTilePlaceholderSelector = function(){
  return ".tile_container:not(.placeholder_container), .creation_placeholder"
}

tilePlaceholderSelector = function(){
  return ".tile_container.placeholder_container:not(.creation_placeholder)"
}