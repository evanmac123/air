hideSpinner = () -> $('.public_board_controls #spinner').hide()
showSpinner = () -> $('.public_board_controls #spinner').show()

updatePublicBoardCallback = (event, data) ->
  hideSpinner()
  event.preventDefault()
  $('.public_board_controls').replaceWith(data)

$('#make_public').on('click', showSpinner)
$('#make_public').on('ajax:success', updatePublicBoardCallback)

