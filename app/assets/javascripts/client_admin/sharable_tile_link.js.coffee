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
    $(".share_options").hide()

  #
  # => Sharable Tile Link
  #
  $("#sharable_tile_link").on('click', (event) ->
    event.preventDefault()
    $(event.target).focus().select()
  )

  $("#sharable_tile_link").on('keydown keyup keypress', (event) ->
    if(!(event.ctrlKey || event.altKey || event.metaKey))
      event.preventDefault()
  )

  $("#share_link").bind(
    copy: ->
      sendTileSharedPing("Via Link")
    cut: ->
      sendTileSharedPing("Via Link")
  )
  #
  # => Share Via
  #
  sendTileSharedPing = (shared_to) ->
    tile_id = $("[data-current-tile-id]").data("current-tile-id")
    $.post "/ping", {event: 'Tile Shared', properties: {shared_to: shared_to, tile_id: tile_id}}

  sharedViaSocialPing = (element) ->
    if element.hasClass("share_via_facebook")
      sendTileSharedPing("Facebook")
    else if element.hasClass("share_via_twitter")
      sendTileSharedPing("Twitter")
    else if element.hasClass("share_via_linkedin") 
      sendTileSharedPing("Linkedin")

  turnOnSharableTile = ->
    if $(".tile_status .on.disengaged").length > 0 # sharable tile is off
      $('#sharable_tile_link_on').click()
      sendSharableTileForm()

  $(".share_via_linkedin, .share_via_facebook, .share_via_twitter").click (e)->
    e.preventDefault()
    sharedViaSocialPing $(this)
    turnOnSharableTile()
    url = $(this).closest("a").attr("href")
    window.open(url, '', 'width=620, height=500')

  $(".share_via_explore").click ->
    sendTileSharedPing("Explore")
    turnOnSharableTile()
    $(".share_options").show()
    $("#share_on").click().click()

  $(".share_via_email").click ->
    sendTileSharedPing("Email")
    turnOnSharableTile()

window.shareSectionIntro = ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks'
    tooltipClass: 'tile_preview_intro'
  })
  $(() -> intro.start())
