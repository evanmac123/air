section = ->
  $("#draft_tiles")

compressSection = (animate = false) ->
  unless animate
    setCompressedSectionClass("show")
  else
    scrollUp()
    animateSectionSliding -compressSectionMargin(), 0 , "up"

compressSectionMargin = ->
  initialHeight = section().outerHeight()
  cutHeight = compressSectionHeight() - initialHeight

compressSectionHeight = ->
  448

moveBottomBoundOfSection = (height) ->
  section().css "margin-bottom", height

makeVisibleAllDraftTilesButHideThem = ->
  setCompressedSectionClass("hide")
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
        setCompressedSectionClass("hide")
      else
        setCompressedSectionClass("show")

scrollUp = ->
  unless iOSdevice()
    $('html, body').scrollTo section(), {duration: 1000}

iOSdevice = ->
  navigator.userAgent.match(/(iPad|iPhone|iPod)/g)

setCompressedSectionClass = (action = "hide") ->
  if action == "hide"
    section().removeClass compressedSectionClass()
  else
    section().addClass compressedSectionClass()
  window.updateTileVisibilityIn("draft")

sectionIsCompressed = ->
  section().hasClass compressedSectionClass()

compressedSectionClass = ->
  "compressed_section"

window.expandDraftSection = ->
  compressSection()

  $(".all_draft").click (e) ->
    e.preventDefault()
    if sectionIsCompressed()
      expandSection()
      $(this).text("Minimize")
    else
      compressSection true
      $(this).text("Show all")
