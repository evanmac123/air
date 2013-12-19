spinner = $('#guest_conversion_form_wrapper .spinner')

convertEmailErrors = (emailErrors) ->
  _.map(emailErrors, (error) ->
    switch error
      when 'is invalid' then 'Please enter a valid email address'
      when 'has already been taken' then 'It looks like that email is already taken. You can <a href="/sign_in">click here</a> to sign in, or contact <a href="mailto:support@hengage.com">support@hengage.com</a> for help.'
      else error
  )

displayErrors = (errors) ->
  $('#guest_conversion_form_wrapper #name_error').html(errors.name)
  $('#guest_conversion_form_wrapper #email_error').html(convertEmailErrors(errors.email))
  $('#guest_conversion_form_wrapper #password_error').html(errors.password)

showSaveProgress = () ->
  $('#save_progress').show()

showSpinner = () -> spinner.show()
hideSpinner = () -> spinner.hide()

clearConversionErrors = () ->
  $('#name_error').html('')
  $('#email_error').html('')
  $('#password_error').html('')

conversionFormClosedCallback = (event) ->
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
$('#save_progress_button').on('click', saveProgressClickCallback)
$('#guest_conversion_form_wrapper .close-lightbox-button').on('click', closeConversionLightbox)

window.lightboxConversionForm = lightboxConversionForm
