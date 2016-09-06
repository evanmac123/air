# This is COFFEE SCRIPT :D


# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  connectDisplayContactPrefs()
############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
phone_number = notification_prefs = 0

# This is a function definition
loadDivs = () ->
  phone_number = $('#user_new_phone_number')
  notification_prefs = $('#notification_prefs')

connectDisplayContactPrefs = () ->
  phone_number.keyup ->
    delay 1, ->
      if phone_number.val().length > 0
        notification_prefs.fadeIn(1000)
      else
        notification_prefs.fadeOut(1000)
