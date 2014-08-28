window.bindVoteupIntro = () ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks'
  })

  $(() -> intro.start())
