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

initIntro = (intro) ->
  if title().attr("data-intro")
    intro.setOptions
      showStepNumbers: false
      skipLabel: 'Got it'
      tooltipClass: tooltipClass()
    intro.start()
    addExplainBtn()

window.suggestionBoxIntro = ->
  intro = introJs()
  initIntro(intro)

  $(document).on "click", "." + explainBtnClass(), (e) ->
    e.preventDefault()
    intro.exit()
    modal().foundation 'reveal', 'open'
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

window.suggestionBoxHelpModal = ->
  # modal().foundation 'reveal', 'open'

  closeBtn().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'close'

  pickUsersBtn().click (e) ->
    e.preventDefault()
    accessModal().foundation 'reveal', 'open'
