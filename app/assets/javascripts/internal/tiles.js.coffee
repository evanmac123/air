grayoutTile = () -> $('#spinner_large').fadeIn('slow')
ungrayoutTile = () -> $('#spinner_large').fadeOut('slow')

loadNextTileWithOffset = (offset, preloadAnimations, predisplayAnimations, tilePosting) ->
  preloadAnimations ?= $.Deferred().resolve() # dummy animation that's pre-resolved
  tilePosting ?= $.Deferred().resolve()
  predisplayAnimations ?= ->

  url = '/tiles/' + $('#slideshow .tile_holder').data('current-tile-id')
  $.get(
    url,
    {partial_only: true, offset: offset,
    completed_only: $('#slideshow .tile_holder').data('completed-only'),
    previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')},
    (data) ->
      $.when(preloadAnimations).then(tilePosting).then ->
        $.when(predisplayAnimations(data, tilePosting)).then ->
          $('#slideshow').html(data.tile_content)
          
          setUpAnswers()
          $('#position').html($('.tile_holder').data('position'))
          if $('#slideshow .tile_holder').data('show-conversion-form') == true
            lightboxConversionForm()

          if $('#slideshow .tile_holder').data('show-start-over') == true
            $('#guest_user_start_over_button').show()
          else
            $('#guest_user_start_over_button').hide()

          ungrayoutTile()
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

disableAllAnswers = ->
  $(".right_multiple_choice_answer:not(.clicked_right_answer)").removeClass("right_multiple_choice_answer").addClass("nerfed_answer").removeAttr("href").removeAttr("data-method").unbind()
  $(".wrong_multiple_choice_answer").removeClass("wrong_multiple_choice_answer").addClass("nerfed_answer").removeAttr("href").removeAttr("data-method").unbind()

postTileCompletion = (event) ->
  link = $(event.target)
  $.post(link.attr('href'))

rightAnswerClicked = (event) ->
  posting = postTileCompletion(event)
  markCompletedRightAnswer(event)
  preloadAnimationsDone = tileCompletedPreloadAnimations(event)
  loadNextTileWithOffset(1, preloadAnimationsDone, predisplayAnimations, posting)

attachRightAnswers = ->
  $('.right_multiple_choice_answer').one("click", (event) ->
    event.preventDefault()
    rightAnswerClicked(event)
    disableAllAnswers()
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
window.grayoutTile = grayoutTile
window.ungrayoutTile = ungrayoutTile

$ ->
  $('#next').click((event) ->
    event.preventDefault()
    grayoutTile()
    loadNextTileWithOffset(1)
  )
  $('#prev').click((event) ->
    event.preventDefault()
    grayoutTile()
    loadNextTileWithOffset(-1)
  )
