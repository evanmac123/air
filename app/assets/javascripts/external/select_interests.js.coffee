submitButton = $("input[type='submit']")
interestCheckboxes = $("input[name='interests[]']")
gameNameTextField = $('#name_game')

checkedInterestCheckboxesCount = ->
  interestCheckboxes.filter(':checked').length


maximumInterestCheckboxesChecked = ->
  checkedInterestCheckboxesCount() == 3


normalizedGameName = ->
  gameNameTextField.val().replace(/(^\s+|^\s$)/, '')


gameNameBlank = ->
  normalizedGameName().length == 0



enableSubmitButtonWhenRequiredInputsFilled = ->
  disableButton = (checkedInterestCheckboxesCount() == 0) || gameNameBlank()
  submitButton.prop('disabled', disableButton)



toggleInterestTileChecking = (event) ->
  paragraph = $(event.target)
  checkbox = paragraph.prev('input[type="checkbox"]')

  if checkbox.prop 'checked'
    checkbox.prop('checked', false).removeAttr('checked');
    paragraph.css 'background', '#4FAA60'
  else 
    unless maximumInterestCheckboxesChecked()
      checkbox.prop('checked', true).attr('checked', 'checked')
      paragraph.css 'background', '#ff7d00'

  enableSubmitButtonWhenRequiredInputsFilled()


$(document).on('click', '.type_tile p', toggleInterestTileChecking)
gameNameTextField.bind 'keyup', enableSubmitButtonWhenRequiredInputsFilled
