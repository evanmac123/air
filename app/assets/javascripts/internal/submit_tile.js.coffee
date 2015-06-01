tooltipClass = ->
  "submit_tile_intro"

tooltip = ->
  $( "." + tooltipClass() )

explainBtnClass = ->
  'intojs-explainbutton'

explainBtn = ->
  $( "." + explainBtnClass() )

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

  # $(window).on 'load', ->
  #   intro.start()
  #   addExplainBtn()
  #
  # => Modal
  #
  bindIntercomOpen askUsSel()
  $("#submit_tile_modal").foundation('reveal', 'open')


