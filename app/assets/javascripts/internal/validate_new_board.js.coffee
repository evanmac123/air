validateNewBoardName = (value, element) ->
  nameValid = false

  validationURL = ["/board_name_validations", value].join('/')
  $.ajax(
    validationURL,
    async: false,
    dataType: 'json',
    success: (data) ->
      nameValid = data.nameValid
  )
  nameValid


bindNewBoardValidations = () ->
  $.validator.addMethod 'validateNewBoardName', validateNewBoardName, "Sorry, that board name is already taken."


  $('#new_board_creation').find('form').validate
    rules:
      'board_name':
        validateNewBoardName: true

window.bindNewBoardValidations = bindNewBoardValidations
