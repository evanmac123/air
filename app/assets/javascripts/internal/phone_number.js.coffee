# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  connectResend()
  connectCancel()
  connectFocus()
  connectHideIfCodePresent()
  showOrHide()


############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

resend_phone_verification_btn = cancel_phone_verification_btn = 0
resend_form = cancel_form = 0
user_new_phone_validation = phone_placeholder = 0

loadDivs = () ->
  resend_phone_verification_btn = $('#resend_phone_verification_btn')
  cancel_phone_verification_btn = $('#cancel_phone_verification_btn')
  resend_form = $('form#resend')
  cancel_form = $('form#cancel')
  user_new_phone_validation = $('#user_new_phone_validation')
  phone_placeholder = $('#phone_placeholder')


connectResend = () ->
  resend_phone_verification_btn.click (e) -> 
    e.preventDefault()
    resend_form.submit()  

connectCancel = () ->
  cancel_phone_verification_btn.click (e) ->
    e.preventDefault()
    cancel_form.submit()  

connectFocus = () ->
  delay 1, ->
    user_new_phone_validation.focus()
  phone_placeholder.click ->
    user_new_phone_validation.focus()

connectHideIfCodePresent = () ->
  user_new_phone_validation.keypress ->
    showOrHide()
  user_new_phone_validation.keyup ->
    showOrHide()
  
showOrHide = () ->
  if user_new_phone_validation.val() == ''
    phone_placeholder.show()
  else
    phone_placeholder.hide()


