$('.start-game-button').prop('disabled', true)

nameInputs = $('.customer-name')
emailInputs = $('.customer-email')


isBlank = (element) -> $.trim(element.val()).length == 0


setStartButtonDisabledUnlessEnoughInput = (event) -> 
  form = $(event.target).parent()
  nameInput = form.find('.customer-name')
  emailInput = form.find('.customer-email')
  startGameButton = form.find('input[type=submit]')
  startGameButton.prop('disabled', isBlank(nameInput) || isBlank(emailInput))


nameInputs.add(emailInputs).keyup(setStartButtonDisabledUnlessEnoughInput)
