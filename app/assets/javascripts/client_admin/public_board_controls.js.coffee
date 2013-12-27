hideSpinner = () -> $('.public_board_controls #spinner').hide()
showSpinner = () -> $('.public_board_controls #spinner').show()

updatePublicBoardControls = (event, data) ->
  hideSpinner()
  event.preventDefault()
  $('.public_board_controls').replaceWith(data)


$(document).on('click', '#make_public, #make_private', showSpinner)
$(document).on('ajax:success', '#make_public, #make_private', updatePublicBoardControls)
