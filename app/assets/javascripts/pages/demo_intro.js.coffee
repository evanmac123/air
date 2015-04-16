$().ready ->
  $("#turn-on-intro-js").click (e) ->
    e.preventDefault()

    intro = introJs()
    intro.setOptions({
      showStepNumbers: false,
      skipLabel: 'Got it, thanks',
      nextLabel: 'Next',
      prevLabel: 'Back'
    })

    $(() -> intro.start())