tooltipClass = ->
  "submit_tile_intro"

tooltip = ->
  $( "." + tooltipClass() )

explainBtnClass = ->
  'intojs-explainbutton'

addExplainBtn = ->
  tooltip()
    .find(".introjs-tooltipbuttons")
    .append "<a class='#{explainBtnClass()}'>How it works</a>"

window.submitTile = ->
  intro = introJs()
  intro.setOptions
    showStepNumbers: false
    skipLabel: 'Got it'
    doneLabel: "How it works"
    tooltipClass: tooltipClass()

  $(window).on 'load', ->
    intro.start()
    addExplainBtn()
