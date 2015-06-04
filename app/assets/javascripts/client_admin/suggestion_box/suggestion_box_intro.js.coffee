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

initIntro = ->
  if title().attr("data-intro")
    intro = introJs()
    intro.setOptions
      showStepNumbers: false
      skipLabel: 'Got it'
      tooltipClass: tooltipClass()
    intro.start()
    addExplainBtn()

window.suggestionBoxIntro = ->
  initIntro()
#
# => Modal
#
modal = ->
  $("#suggestion_box_help_modal")

window.suggestionBoxHelpModal = ->
  modal().foundation 'reveal', 'open'
