window.expandDraftSection = ->
  $().ready ->
    section = $("#draft_tiles")
    #removeSectionInitialHeight(section)
    compressSection section

  $("#draft_tiles").mousedown (e) ->
    #e.preventDefault()
    section = $(this)
    if sectionIsCompressed section
      expandSection section

  $(".completed_tiles_containment").click (e) ->
    section = $("#draft_tiles")
    unless section.hasClass compressedSectionClass()
      compressSection section, true

  sectionParams = (section) ->
    name = section.attr("id")
    tiles = section.find(".tile_thumbnail:not(.placeholder_tile)")
    presented_ids = ($(tile).data("tile_id") for tile in tiles)
    {name: name, presented_ids: presented_ids}

  compressSection = (section, animate = false) ->
    cutHeight = compressSectionMargin(section)
    unless animate
      section.css "margin-bottom", (cutHeight + "px")
      compressedSectionOverlay(section, "show")
    else
      scrollTo section
      animateSectionSliding section, -cutHeight, 0 , "up"

  compressSectionMargin = (section) ->
    initialHeight = section.outerHeight()
    cutHeight = compressSectionHeight() - initialHeight

  compressSectionHeight = ->
    420
  ###
  removeSectionInitialHeight = (section) ->
    section.css "height", ""
  ###
  expandSection = (section) ->
    compressedSectionOverlay(section, "hide")

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
        else
          compressedSectionOverlay(section, "show")

  scrollTo = (container) ->
    unless iOSdevice()
      $('html, body').scrollTo(container, {duration: 500})

  iOSdevice = ->
    navigator.userAgent.match(/(iPad|iPhone|iPod)/g)

  compressedSectionOverlay = (section, action = "hide") ->
    overlay = section.find "." + compressedSectionOverlayClass()
    if action == "hide"
      overlay.hide()
    else
      overlay.show()

  setCompressedSectionClass = (section, action = "hide") ->
    if action == "hide"
      section.removeClass compressedSectionClass()
    else
      section.addClass compressedSectionClass()

  sectionIsCompressed = (section) ->
    section.hasClass compressedSectionClass()

  compressedSectionClass = ->
    "compressed_section"

  compressedSectionOverlayClass = ->
    "expand_overlay"