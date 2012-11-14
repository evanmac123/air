# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->

  # Note we will load divs once now, and again later after the intercom window opens
  loadDivs()
  connectClickWidget()

############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
intercom = header = h1_greeting = widget = 0

# This is a function definition
loadDivs = () ->
  intercom = $('#IntercomNewMessageContainer')
  header = intercom.find('.header')
  h1_greeting = header.find('h1')
  widget = $('#IntercomDefaultWidget')

addWordsAfterWindowLoads = () -> 
  if $('#IntercomNewMessageContainer .header h1').length > 0
    #console.log 'already there'
    loadDivs()
    addWordsToMessageBox()
  else
    #console.log 'not yet'
    delay 1, ->
      addWordsAfterWindowLoads()


addWordsToMessageBox = () ->
  h1_greeting.after("<h2>Ask us a question or offer suggestions, and<br>we'll get back to you soon!</h2>")

connectClickWidget = () ->
  widget.live 'click',  ->
    addWordsAfterWindowLoads()


