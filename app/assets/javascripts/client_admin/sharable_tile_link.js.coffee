window.sharableTileLink = ->
  #
  # => Share Tile Switcher
  #
  $('#sharable_tile_link_on').click ->
    sendSharableTileForm()
    turnOnSharing()

  $('#sharable_tile_link_off').click ->
    sendSharableTileForm()
    turnOffSharing()

  sendSharableTileForm = ->
    $("#sharable_link_form").submit()

  turnOnSharing = ->
    $(".tile_status .off").removeClass("engaged").addClass("disengaged")
    $(".tile_status .on").removeClass("disengaged").addClass("engaged")
    $("#sharable_tile_link").removeAttr("disabled")

  turnOffSharing = ->
    $(".tile_status .off").removeClass("disengaged").addClass("engaged")
    $(".tile_status .on").removeClass("engaged").addClass("disengaged")
    $("#sharable_tile_link").attr("disabled", "disabled")
    $(".share_options").css("display", "none")

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
  #
  # => Share Via
  #
  $(".share_via_linkedin, .share_via_facebook, .share_via_twitter").click (e)->
    e.preventDefault()

    if $(".tile_status .on.disengaged").length > 0 # sharable tile is off
      $('#sharable_tile_link_on').click()
      sendSharableTileForm()

    url = $(this).closest("a").attr("href")
    window.open(url, '', 'width=620, height=500')

  $(".share_via_explore").click ->
    $(".share_options").css("display", "block")
