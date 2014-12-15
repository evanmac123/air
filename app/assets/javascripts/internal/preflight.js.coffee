window.preflight = (url) ->
  # do nothing with the requested resource--except keep it in cache.
  $.ajax(url, {
    cache: true
  })
  
window.bindPreflightToEvent = (eventName, selector, url) ->
  $(selector).on(eventName, () ->
    preflight(url)
  )
