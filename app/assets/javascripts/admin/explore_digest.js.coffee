window.bindAddExploreDigestTileIDField = ->
  $('#add_tile_id').click (event) ->
    event.preventDefault()
    $('#tile_ids_container').append('<input type="text" name="explore_digest_form[tile_ids][]">')
    
