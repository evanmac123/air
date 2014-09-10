window.tileShareLink = () ->
  $("#share_link").on('click', (event) ->
    event.preventDefault()
    $(event.target).focus().select()
  )

  $("#share_link").on('keydown keyup keypress', (event) ->
    if(!(event.ctrlKey || event.altKey || event.metaKey))
      event.preventDefault()
  )