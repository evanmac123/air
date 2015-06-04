#
# => Intro
#
titleSel = ->
  "#suggestion_box_title"

title = ->
  $( titleSel() )

tooltipClass = ->
  "suggestion_box_intro"

tooltip = ->
  $( "." + tooltipClass() )

explainBtnClass = ->
  'intojs-explainbutton'

addExplainBtn = ->
  tooltip()
    .find(".introjs-tooltipbuttons")
    .append "<a class='#{explainBtnClass()}'>How it works</a>"

prompt = ->
  $(".ideas_prompt")

closePromptIcon = ->
  prompt().find(".fa-close")

promptVisibile = (show)->
  if show
    prompt().show()
  else
    prompt().hide()

updateFlag = ->
  $.post('/intro_viewed_status', {suggestion_box_prompt_seen: true, _method: 'PUT'})

initIntro = (intro) ->
  if title().attr("data-intro")
    promptVisibile(false)

    intro.setOptions
      showStepNumbers: false
      skipLabel: 'Got it'
      tooltipClass: tooltipClass()
    intro.start()
    addExplainBtn()
    intro.oncomplete ->
      promptVisibile(true)

window.suggestionBoxIntro = ->
  intro = introJs()
  initIntro(intro)

  $(document).on "click", "." + explainBtnClass(), (e) ->
    e.preventDefault()
    intro.exit()
    promptVisibile(true)
    modal().foundation 'reveal', 'open'

  closePromptIcon().click (e) ->
    e.preventDefault()
    prompt().remove()
    updateFlag()

  prompt().click (e) ->
    e.preventDefault()
    accessModal().foundation 'reveal', 'open'
#
# => Modal
#
modal = ->
  $("#suggestion_box_help_modal")

closeBtn = ->
  modal().find(".close")

pickUsersBtn = ->
  modal().find(".submit")

accessModal = ->
  $('#suggestions_access_modal')

helpBtn = ->
  $(".suggestion_box_header .help")

window.suggestionBoxHelpModal = ->
  # modal().foundation 'reveal', 'open'

  helpBtn().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'open'

  closeBtn().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'close'

  pickUsersBtn().click (e) ->
    e.preventDefault()
    accessModal().foundation 'reveal', 'open'

