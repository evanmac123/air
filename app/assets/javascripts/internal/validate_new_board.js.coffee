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
  )
  nameValid


bindNewBoardValidations = () ->
  $.validator.addMethod 'validateNewBoardName', validateNewBoardName, "Sorry, that board name is already taken."


  $('#new_board_creation').find('form').validate
    rules:
      'board_name':
        validateNewBoardName: true
    onkeyup:
      false

window.bindNewBoardValidations = bindNewBoardValidations
