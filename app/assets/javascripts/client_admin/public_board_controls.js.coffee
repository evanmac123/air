hideSpinner = () -> $('.public_board_controls #spinner').hide()
showSpinner = () -> $('.public_board_controls #spinner').show()

updatePublicBoardControls = (event, data) ->
  hideSpinner()
  event.preventDefault()
  $('.public_board_controls').replaceWith(data)

switchPublicStatusIfEngaged = (event) ->
  if $(event.target).hasClass 'engaged'
    event.preventDefault()
  else
    showSpinner()

$(document).on('click', '#on_toggle, #off_toggle', switchPublicStatusIfEngaged)
$(document).on('ajax:success', '#on_toggle, #off_toggle', updatePublicBoardControls)

$(document).on('keydown keyup keypress', '#public_board_field', (event) ->
  if(!(event.ctrlKey || event.altKey || event.metaKey))
    event.preventDefault()
)

$(document).on('click', '#public_board_field', (event) ->
  event.preventDefault()
  $(event.target).focus().select()
)
