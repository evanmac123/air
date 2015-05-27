window.submittedTileMenuIntro = ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it'
    tooltipClass: 'tile_preview_intro'
  })
  $(() -> intro.start())
