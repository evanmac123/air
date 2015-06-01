#
# => Intro
#
tooltipClass = ->
  "submit_tile_intro"

tooltip = ->
  $( "." + tooltipClass() )

explainBtnClass = ->
  'intojs-explainbutton'
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

window.submitTile = ->
  #
  # => Intro
  #
  intro = introJs()
  intro.setOptions
    showStepNumbers: false
    skipLabel: 'Got it'
    doneLabel: "How it works"
    tooltipClass: tooltipClass()

  $(window).on 'load', ->
    intro.start()
    addExplainBtn()

  $(document).on "click", "." + explainBtnClass(), ->
    intro.exit()
    modal().foundation 'reveal', 'open'
  #
  # => Modal
  #
  bindIntercomOpen askUsSel()
  
  closeBtn().click ->
    modal().foundation 'reveal', 'close'


