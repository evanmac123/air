first_ping_after_load = true

sendViewedTilePing = (tile_id) ->
  via = 0
  if (first_ping_after_load)
    via = 'thumbnail'
    first_ping_after_load = false
  else
    via = 'next_button'
  properties = {via: via, tile_id: tile_id}
  data = {event: "viewed tile", properties: properties}
  $.post('/ping', data)

loadNextTileWithOffset = (offset) ->
  $('#spinner_large').show()

  url = '/tiles/' + $('#slideshow .tile_holder').data('current-tile-id')
  $.get(
    url,
    {partial_only: true, offset: offset, 
    completed_only: $('#slideshow .tile_holder').data('completed-only'),
    previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')},
    (data) ->
      $('#slideshow').html(data)
      $('#spinner_large').hide()
      setUpAnswers()
      $('#position').html($('.tile_holder').data('position'))
      if $('#slideshow .tile_holder').data('show-conversion-form') == true
        lightboxConversionForm();
  )

attachWrongAnswer = (answerLink, target) ->
  answerLink.click((event) ->
    event.preventDefault()
    target.html("Sorry, that's not it. Try again!")
    target.slideDown(250)
    $(this).addClass("clicked_wrong")
  )

nerfNerfedAnswers = ->
  $('.nerfed_answer').click((event) -> event.preventDefault())

markCompletedRightAnswer = (nodes) ->
  nodes.addClass 'clicked_right_answer'

attachRightAnswers = ->
  $('.right_multiple_choice_answer').one("click", (event) ->
    event.preventDefault()
    markCompletedRightAnswer $(this)
    $('#right_answer_target').click()
    $(event.target).click((event) -> event.preventDefault())
  )

attachWrongAnswers = ->
  _.each($('.wrong_multiple_choice_answer'), (wrongAnswerLink) ->
    wrongAnswerLink = $(wrongAnswerLink)
    target = wrongAnswerLink.siblings('.wrong_answer_target')
    attachWrongAnswer(wrongAnswerLink, target)
  )

setUpAnswers = ->
  nerfNerfedAnswers()
  attachRightAnswers()
  attachWrongAnswers()

window.loadNextTileWithOffset = loadNextTileWithOffset
window.setUpAnswers = setUpAnswers

$ ->
  $('#next').click((event) ->
    event.preventDefault()
    loadNextTileWithOffset(1)
  )
  $('#prev').click((event) ->
    event.preventDefault()
    loadNextTileWithOffset(-1)
  )
