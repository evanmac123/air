updateShareIntroSeen = () ->
  $.post('/intro_viewed_status', {share_link_intro_seen: true, _method: 'PUT'})

changeDispatchTable =
  'share_bar': updateShareIntroSeen

dispatchIntroChange = (elementChangingTo) ->
  step_name = $(elementChangingTo).data('step-name')
  handler = changeDispatchTable[step_name]
  if handler?
    handler(elementChangingTo)

window.bindTilePreviewIntros = () ->
  intro = introJs()
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: 'Got it, thanks',
    tooltipClass: 'tile_preview_intro'
  })

  intro.onchange dispatchIntroChange

  $(() -> intro.start())
