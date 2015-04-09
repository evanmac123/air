addTileImages = (tileImagesString) ->
  tileImages = $.parseJSON tileImagesString
  for tileImage in tileImages
    $(".tile_images").append(tileImage)

window.imageLibraryScroll = ->
  # $('.image_library').infinitescroll
  #   debug: true,
  #   nextSelector: ".image_library .pagination a[rel='next']",
  #   navSelector:  ".image_library .pagination",
  #   #itemSelector: ".image_library .tile_image_block",
  #   #bufferPx: 200,
  #   dataType: 'json',
  #   #localMode: true,
  #   appendCallback: false
  # , (data) ->
  #   console.log data
  #   addTileImages data.tileImages

  $('.image_library').jscroll
    debug: true,
    loadingHtml: '<p>Loading...</p>',
    padding: 20,
    nextSelector: ".pagination a[rel='next']",
    pagingSelector: ".paginator",
    callback: (data) ->
      console.log data
      addTileImages data.tileImages

  # waypoint = new Waypoint
  #   element: $(".image_library .pagination a[rel='next']")[0],
  #   handler: ->
  #     console.log "ogogog"

  # $('.image_library').scroll ->
  #   console.log "1. #{$(this).scrollTop()} 2. #{$(document).height()} 3. #{$(this).height()}"
  #   if $(this).scrollTop() == $(document).height() - $(this).height()
  #     console.log "fdff"