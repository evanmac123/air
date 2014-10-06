window.sharableTileLink = ->
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
