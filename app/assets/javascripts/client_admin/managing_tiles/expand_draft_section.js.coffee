section = ->
  $("#draft_tiles")

selectedBlockName = ->
  if $("#draft.selected").length > 0
    'draft'
  else
    'suggestion_box'

compressSection = (animate = false) ->
  if animate
    # two simultaneous actions
    scrollUp()
    animateSectionSliding -compressSectionMargin(), 0 , "up"
  else
    setCompressedSectionClass("add")
    $(".all_draft").text("Show all")

window.compressSection = compressSection

compressSectionMargin = ->
  initialHeight = section().outerHeight()
  cutHeight = compressSectionHeight() - initialHeight

compressSectionHeight = ->
  448

moveBottomBoundOfSection = (height) ->
  section().css "margin-bottom", height

makeVisibleAllDraftTilesButHideThem = ->
  setCompressedSectionClass("remove")
  moveBottomBoundOfSection compressSectionMargin() + "px"

expandSection = ->
  makeVisibleAllDraftTilesButHideThem()
  startProgress = parseInt section().css("margin-bottom")
  animateSectionSliding -startProgress, startProgress, "down"

animateSectionSliding = (stepsNum, startProgress, direction = "down") ->
  section().addClass("counting")
  $({progressCount: 0}).animate 
    progressCount: stepsNum
  ,
    duration: 1000
    easing: 'linear'
    step: (progressCount) ->
      progressNew = if direction == "down"
        startProgress + parseInt(progressCount)
      else
        startProgress - parseInt(progressCount)

      moveBottomBoundOfSection (progressNew + "px")
    complete: ->
      section().removeClass("counting")
      moveBottomBoundOfSection "" # just remove current value
      if direction == "down" 
        setCompressedSectionClass("remove")
      else
        setCompressedSectionClass("add")

scrollUp = ->
  unless iOSdevice()
    $('html, body').scrollTo section(), {duration: 1000}

iOSdevice = ->
  navigator.userAgent.match(/(iPad|iPhone|iPod)/g)

setCompressedSectionClass = (action = "remove") ->
  if action == "remove"
    section().removeClass compressedSectionClass()
  else
    section().addClass compressedSectionClass()
  window.updateTileVisibilityIn selectedBlockName()

sectionIsCompressed = ->
  section().hasClass compressedSectionClass()

compressedSectionClass = ->
  "compressed_section"

window.expandDraftSectionOrSuggestionBox = ->
  compressSection()

  $(".all_draft").click (e) ->
    e.preventDefault()
    if sectionIsCompressed()
      expandSection()
      $(this).text("Minimize")
    else
      compressSection true
      $(this).text("Show all")
