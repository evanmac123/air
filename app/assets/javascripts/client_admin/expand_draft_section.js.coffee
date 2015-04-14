compressSection = (section, animate = false) ->
  cutHeight = compressSectionMargin(section)
  unless animate
    section.css "margin-bottom", (cutHeight + "px")
  else
    scrollTo section
    animateSectionSliding section, -cutHeight, 0 , "up"

compressSectionMargin = (section) ->
  initialHeight = section.outerHeight()
  cutHeight = compressSectionHeight() - initialHeight

compressSectionHeight = ->
  420
expandSection = (section) ->
  startProgress = parseInt section.css("margin-bottom")
  animateSectionSliding(section, -startProgress, startProgress, "down")

animateSectionSliding = (section, stepsNum, startProgress, direction = "down") ->
  section.addClass("counting")
  setCompressedSectionClass(section, "show")

  $({progressCount: 0}).animate 
    progressCount: stepsNum
  ,
    duration: 500
    easing: 'linear'
    step: (progressCount) ->
      progressNew = startProgress
      if direction == "down"
        progressNew += parseInt(progressCount)
      else
        progressNew -= parseInt(progressCount)

      section.css "margin-bottom", (progressNew + "px")
    complete: ->
      section.removeClass("counting")
      if direction == "down" 
        section.css "margin-bottom", ""
        setCompressedSectionClass(section, "hide")

scrollTo = (container) ->
  unless iOSdevice()
    $('html, body').scrollTo(container, {duration: 500})

iOSdevice = ->
  navigator.userAgent.match(/(iPad|iPhone|iPod)/g)

setCompressedSectionClass = (section, action = "hide") ->
  if action == "hide"
    section.removeClass compressedSectionClass()
  else
    section.addClass compressedSectionClass()

sectionIsCompressed = (section) ->
  section.hasClass compressedSectionClass()

compressedSectionClass = ->
  "compressed_section"

window.expandDraftSection = ->
  section = $("#draft_tiles")
  compressSection section

  $(".all_draft").click (e) ->
    e.preventDefault()
    section = $("#draft_tiles")
    if sectionIsCompressed section
      expandSection section
      $(this).text("Minimize")
    else
      compressSection section, true
      $(this).text("Show all")
