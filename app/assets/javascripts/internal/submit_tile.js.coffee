#
# => Intro
#
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

window.submitTileIntro = ->
  intro = introJs()
  intro.setOptions
    showStepNumbers: false
    skipLabel: 'Got it'
    tooltipClass: tooltipClass()

  $(window).on 'load', ->
    intro.start()
    addExplainBtn()

  $(document).on "click", "." + explainBtnClass(), (e) ->
    e.preventDefault()
    intro.exit()
    modal().foundation 'reveal', 'open', {animation: "fade", closeOnBackgroundClick: true}
#
# => Modal
#
modal = ->
  $("#submit_tile_modal")

closeBtn = ->
  modal().find(".close")

askUsSel = ->
  '#ask_us'

suggestLink = ->
  $(".suggest_tile_redirect")

infoIcon = ->
  $("#creation .help")

window.submitTileModal = ->
  bindIntercomOpen askUsSel()

  # closeBtn().add(suggestLink()).click (e) ->
  closeBtn().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'close'

  infoIcon().click (e) ->
    e.preventDefault()
    modal().foundation 'reveal', 'open', {animation: "fade", closeOnBackgroundClick: true}

  # suggestLink().click (e) ->
  #   e.preventDefault()
  #   $("#submit_tile").click()
