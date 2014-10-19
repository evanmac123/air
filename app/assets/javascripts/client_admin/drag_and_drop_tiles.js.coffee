window.dragAndDropTiles = ->
  $( "#draft, #active, #archive" ).sortable({
    connectWith: ".manage_section",
    items: ".tile_container:not(.placeholder_container)"
  }).disableSelection();