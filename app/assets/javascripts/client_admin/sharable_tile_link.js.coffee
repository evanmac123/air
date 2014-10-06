window.sharableTileLink = ->
  #
  # => Share Tile Switcher
  #
  $('#sharable_tile_link_on').click ->
    $(".edit_multiple_choice_tile").submit()
    turnOnSharing()

  $('#sharable_tile_link_off').click ->
    $(".edit_multiple_choice_tile").submit()
    turnOffSharing()

  turnOnSharing = ->
    $(".tile_status .off").removeClass("engaged").addClass("disengaged")
    $(".tile_status .on").removeClass("disengaged").addClass("engaged")
    $("#sharable_tile_link").removeAttr("disabled")

  turnOffSharing = ->
    $(".tile_status .off").removeClass("disengaged").addClass("engaged")
    $(".tile_status .on").removeClass("engaged").addClass("disengaged")
    $("#sharable_tile_link").attr("disabled", "disabled")

  #
  # => Share Tile Link
  #
  $("#sharable_tile_link").on('click', (event) ->
    event.preventDefault()
    $(event.target).focus().select()
  )

  $("#sharable_tile_link").on('keydown keyup keypress', (event) ->
    if(!(event.ctrlKey || event.altKey || event.metaKey))
      event.preventDefault()
  )
