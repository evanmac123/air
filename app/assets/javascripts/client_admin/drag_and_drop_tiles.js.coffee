window.dragAndDropTiles = ->
  $( "#draft_tiles" ).sortable({
    items: ".tile_container:not(.placeholder_container)"
  });
  $( "#draft" ).disableSelection();