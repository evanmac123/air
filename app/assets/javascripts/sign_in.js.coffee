# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  showOrHidePlaceholder()
  connectPasswordFocus()
  connectDetectPasswordWhenTypingEmail()

############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
session_password = password_placeholder = session_email = 0

# This is a function definition
loadDivs = () ->
  session_password = $('#session_password')
  session_email = $('#session_email')
  password_placeholder = $('#password_placeholder')

showOrHidePlaceholder = () ->
  delay 1, ->
    if session_password.val() == ''
      password_placeholder.show()
    else
      password_placeholder.hide()

connectDetectPasswordWhenTypingEmail = () ->
  session_email.keypress -> 
    showOrHidePlaceholder()
  session_email.keyup ->
    showOrHidePlaceholder()

connectPasswordFocus = () ->
  session_password.focus ->
    # There is only a delay here so it will work properly when tabbing into from the email field
    delay 1, ->
      password_placeholder.hide()
  session_password.blur ->
    showOrHidePlaceholder()
