window.tileShareLink = () ->
  $("#share_link").on('click', (event) ->
    event.preventDefault()
    $(event.target).focus().select()
  )

  $("#share_link").on('keydown keyup keypress', (event) ->
    if(!(event.ctrlKey || event.altKey || event.metaKey))
      event.preventDefault()
  )

  $("#share_link").bind(
    copy: ->
      pingShareTile("Copied tile link")
    cut: ->
      pingShareTile("Copied tile link")
  )

  $(".share_linkedin").click ->
    pingShareTile("Clicked share tile via LinkedIn")

  $(".share_mail").click ->
    pingShareTile("Clicked share tile via email")

  pingShareTile = (action) ->
    tile_id = $("[data-current-tile-id]").data("current-tile-id")
    $.post("/ping", {event: 'Explore page - Interaction', properties: {action: action, tile_id: tile_id}})
