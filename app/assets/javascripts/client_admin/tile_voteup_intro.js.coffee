window.bindVoteupIntro = () ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks',
    tooltipClass: 'tile_preview_intro'
  })

  $(() -> intro.start())
