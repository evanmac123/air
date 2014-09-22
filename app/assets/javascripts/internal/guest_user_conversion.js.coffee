locationLinkSelected = (locationNameField) ->
  (event, ui) ->
    event.preventDefault()
    locationNameField.val(ui.item.label)

bindLocationAutocomplete = (sourceSelector, targetSelector, searchURL) ->
  locationNameField = $(sourceSelector)

  locationNameField.autocomplete({
    appendTo: targetSelector,
    source: searchURL,
    select: locationLinkSelected(locationNameField)
  })
  
spinner = $('#guest_conversion_form_wrapper .spinner')

convertEmailErrors = (emailErrors) ->
  _.map(emailErrors, (error) ->
    switch error
      when 'is invalid' then 'Whoops. Enter a valid email address.'
      when 'Please enter a valid email address' then 'Whoops. Enter a valid email address.'
      when 'has already been taken' then 'It looks like that email is already taken. You can <a href="/sign_in">click here</a> to sign in, or contact <a href="mailto:support@air.bo">support@air.bo</a> for help.'
      else error
  )

ensurePeriods = (errors) -> _.map(errors, ensurePeriod)

ensurePeriod = (error) ->
  if error[error.length - 1] == "."
  then error
  else error + '.'

displayErrors = (errors) ->
  if !(errors.email && 'has already been taken' in errors.email)
    $('#guest_conversion_form_wrapper #name_error').html(ensurePeriods(errors.name))
    $('#guest_conversion_form_wrapper #password_error').html(ensurePeriods(errors.password))

  $('#guest_conversion_form_wrapper #email_error').html(ensurePeriods(convertEmailErrors(errors.email)))

showSaveProgress = () ->
  $('#save_progress').show()

showSpinner = () -> spinner.show()
hideSpinner = () -> spinner.hide()

clearConversionErrors = () ->
  $('#name_error').html('')
  $('#email_error').html('')
  $('#password_error').html('')

conversionFormClosedCallback = (event) ->
  $('.js_lb_overlay').hide() # should happen automatically, doesn't
  showSaveProgress()

conversionStartCallback = (event) ->
  showSpinner()
  clearConversionErrors()

conversionResponseCallback = (event, data) ->
  hideSpinner()
  if data.status == 'success'
    window.location.href = "/activity"
  else
    displayErrors data.errors

saveProgressClickCallback = (event) ->
  event.preventDefault()
  lightboxConversionForm()

lightboxConversionForm = () ->
  $('#guest_conversion_form_wrapper').lightbox_me({onClose: conversionFormClosedCallback})

closeConversionLightbox = (event) ->
  event.preventDefault()
  $('#guest_conversion_form_wrapper').trigger('close')

$('#guest_conversion_form').on('submit', conversionStartCallback).on('ajax:success', conversionResponseCallback)
$('.open_save_progress_form').on('click', saveProgressClickCallback)
$('#guest_conversion_form_wrapper .close-lightbox-button').on('click', closeConversionLightbox)

window.lightboxConversionForm = lightboxConversionForm
window.bindLocationAutocomplete = bindLocationAutocomplete
