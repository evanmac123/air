window.submittedTileMenuIntro = ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    doneLabel: 'Got it'
    tooltipClass: 'tile_preview_intro'
  })
  $(() -> intro.start())
