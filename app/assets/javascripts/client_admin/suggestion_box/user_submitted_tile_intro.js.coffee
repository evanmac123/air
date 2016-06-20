tooltipClass = ->
  "user_submitted_tile_intro"

initIntro = (intro) ->
  intro.setOptions
    showStepNumbers: false
    doneLabel: 'Got it'
    tooltipClass: tooltipClass()
  intro.start()

addIntroToTile = ->
  intro = "Accept the Tile to use it in your Board, " +
          "or Ignore it to mark it as reviewed."
  $(".tile_thumbnail.user_submitted").first().attr("data-intro", intro)

window.userSubmittedTileIntro = (show) ->
  return if show != "true"
  addIntroToTile()

  intro = introJs()
  initIntro(intro)
