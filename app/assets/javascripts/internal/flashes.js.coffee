sendPersistentMessageClosedPing = () ->
  $.post("/ping", {event: 'Saw Persistent Welcome Message', properties: {action: 'Exited message'}})

window.bindCloseFlash = (selector, sendPing) ->
  $(selector).click((event) ->
    $('#flash').slideUp()
    if sendPing
      sendPersistentMessageClosedPing()
  )
