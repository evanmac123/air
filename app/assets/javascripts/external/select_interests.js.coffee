submitButton = $("input[type='submit']")
interestCheckboxes = $("input[name='interests[]']")
gameNameTextField = $('#name_game')
nameErrorMessage = $('#name_error_message')
prioritiesErrorMessage = $('#priorities_error_message')



checkedInterestCheckboxesCount = ->
  interestCheckboxes.filter(':checked').length


maximumInterestCheckboxesChecked = ->
  checkedInterestCheckboxesCount() == 3


normalizedGameName = ->
  gameNameTextField.val().replace(/(^\s+|^\s$)/, '')


gameNameBlank = ->
  normalizedGameName().length == 0


noInterestsChecked = ->
  checkedInterestCheckboxesCount() == 0


formShouldBeDisabled = -> noInterestsChecked() || gameNameBlank()


showErrors = ->
  nameErrorMessage.toggle gameNameBlank()
  prioritiesErrorMessage.toggle noInterestsChecked()
  

cancelFormSubmitIfMissingRequiredDocumentation = (e) ->
  if formShouldBeDisabled()
    showErrors()
    e.preventDefault()


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



$(document).on('click', '.type_tile p', toggleInterestTileChecking)
$(document).on('submit', 'form', cancelFormSubmitIfMissingRequiredDocumentation)
