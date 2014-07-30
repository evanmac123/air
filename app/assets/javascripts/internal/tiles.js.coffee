grayoutTile = () -> $('#spinner_large').fadeIn('slow')
ungrayoutTile = () -> $('#spinner_large').fadeOut('slow')

showOrHideStartOverButton = (showFlag) ->
  if showFlag
    $('#guest_user_start_over_button').show()
  else
    $('#guest_user_start_over_button').hide()

loadNextTileWithOffset = (offset, preloadAnimations, predisplayAnimations, tilePosting) ->
  afterPosting = typeof(tilePosting) != 'undefined'

  preloadAnimations ?= $.Deferred().resolve() # dummy animation that's pre-resolved
  tilePosting ?= $.Deferred().resolve()
  predisplayAnimations ?= -> $.Deferred().resolve()

  url = '/tiles/' + $('#slideshow .tile_holder').data('current-tile-id')
  $.when(preloadAnimations).then(tilePosting).then ->
    $.get(
      url,
      {partial_only: true, offset: offset, after_posting: afterPosting,
      completed_only: $('#slideshow .tile_holder').data('completed-only'),
      previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')},
      (data) ->
        $.when(predisplayAnimations(data, tilePosting)).then ->
          if data.all_tiles_done == true && afterPosting
            $('.content .container.row').replaceWith(data.tile_content)
            showOrHideStartOverButton(data.show_start_over_button == true)

          else
            $('#slideshow').html(data.tile_content)
            setUpAnswers()
            $('#position').html($('.tile_holder').data('position'))
            showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') == true)

            ungrayoutTile()

          if data.show_conversion_form == true
            lightboxConversionForm()
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

findCsrfToken = () ->
  $('meta[name="csrf-token"]').attr('content')

postTileCompletion = (event) ->
  link = $(event.target)
  $.ajax({
    type: "POST",
    url: link.attr('href'),
    headers: {
      'X-CSRF-Token': findCsrfToken()
    }
  })

pingRightAnswerInPreview = () ->
  $.post("/ping", {event: 'Explore page - Interaction', properties: {action: 'Clicked Answer'}})

rightAnswerClicked = (event) ->
  posting = postTileCompletion(event)
  markCompletedRightAnswer(event)
  preloadAnimationsDone = tileCompletedPreloadAnimations(event)
  loadNextTileWithOffset(1, preloadAnimationsDone, predisplayAnimations, posting)

rightAnswerClickedForPreview = (event) ->
  pingRightAnswerInPreview()
  markCompletedRightAnswer(event)

attachRightAnswers = ->
  $('.right_multiple_choice_answer').one("click", (event) ->
    event.preventDefault()
    rightAnswerClicked(event)
    #disableAllAnswers() 
    # with this spec/acceptance/guest_user/starts_over_spec.rb:78 fails
    # because it disables next tile. also without countdown we don't need it
  )

attachRightAnswersForPreview = ->
  $('.right_multiple_choice_answer').one("click", (event) ->
    event.preventDefault()
    rightAnswerClickedForPreview(event)
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

setUpAnswersForPreview = ->
  attachRightAnswersForPreview()
  attachWrongAnswers()

window.loadNextTileWithOffset = loadNextTileWithOffset
window.setUpAnswers = setUpAnswers
window.setUpAnswersForPreview = setUpAnswersForPreview
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
