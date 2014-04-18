validateNewBoardName = (value, element) ->
  nameValid = false

  $(element).removeClass('valid')

  validationURL = ["/board_name_validations", value].join('/')
  $.ajax(
    validationURL,
    async: false,
    dataType: 'json',
    success: (data) ->
      nameValid = data.nameValid
      if nameValid
        $(element).addClass('valid')
      else
        $(element).removeClass('valid')
        enableNewBoardCreationButton()
  )
  nameValid

newBoardCreationButton = () -> $('#new_board_creation form input[type=submit]')

disableNewBoardCreationButton = () -> newBoardCreationButton().attr('disabled', true)
enableNewBoardCreationButton = () -> newBoardCreationButton().removeAttr('disabled')

bindNewBoardValidations = () ->
  $.validator.addMethod 'validateNewBoardName', validateNewBoardName, "Sorry, that board name is already taken."

  $('#new_board_creation').find('form').validate
    rules:
      'board_name':
        validateNewBoardName: true
    onkeyup:
      false

window.newBoardCreationButton = newBoardCreationButton
window.disableNewBoardCreationButton = disableNewBoardCreationButton
window.enableNewBoardCreationButton = enableNewBoardCreationButton
window.bindNewBoardValidations = bindNewBoardValidations
