#
# => Intro
#
tooltipClass = ->
  "submit_tile_intro"

tooltip = ->
  $( "." + tooltipClass() )

explainBtnClass = ->
  'intojs-explainbutton'

window.submitTileIntro = ->
  intro = introJs()
  intro.setOptions
    showStepNumbers: false
    skipLabel: 'Got it'
    doneLabel: "How it works"
    tooltipClass: tooltipClass()

  $(window).on 'load', ->
    intro.start()
    addExplainBtn()

  $(document).on "click", "." + explainBtnClass(), (e) ->
    e.preventDefault()
    intro.exit()
    modal().foundation 'reveal', 'open'
#
# => Modal
#
modal = ->
  $("#submit_tile_modal")

closeBtn = ->
  modal().find(".close")

askUsSel = ->
  '#ask_us'

addExplainBtn = ->
  tooltip()
    .find(".introjs-tooltipbuttons")
    .append "<a class='#{explainBtnClass()}'>How it works</a>"

infoIcon = ->
  $("#info_submit_tile")

window.submitTileModal = ->
  bindIntercomOpen askUsSel()
  
  closeBtn().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'close'

  infoIcon().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'open'


