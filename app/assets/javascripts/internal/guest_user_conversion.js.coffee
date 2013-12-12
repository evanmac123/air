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

conversionResponseCallback = (event, data) ->
  if data.status == 'success'
    window.location.href = "/activity"
  else
    displayErrors data.errors

$('#guest_conversion_form').on('ajax:success', conversionResponseCallback)
