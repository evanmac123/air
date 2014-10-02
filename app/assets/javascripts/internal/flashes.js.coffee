window.bindCloseFlash = (selector) ->
  $(selector).click((event) -> $('#flash').slideUp())
