window.tileImages = ->
  $("#tile_image_image").change ->
    $("form#new_tile_image").submit()