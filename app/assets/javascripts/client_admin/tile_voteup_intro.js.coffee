window.bindVoteupIntro = () ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks',
    tooltipClass: 'voteup_intro'
  })

  $(() -> intro.start())
