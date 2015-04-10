nextSelector = ->
  ".pagination a[rel='next']"

addTileImages = (tileImagesString) ->
  tileImages = $.parseJSON tileImagesString
  for tileImage in tileImages
    $(".tile_images").append(tileImage)

updateNextPageLink = (link) ->
  if link
    $(nextSelector()).attr("href", link)
  else
    $(nextSelector()).remove()

window.imageLibraryScroll = (imagePath) ->
  $('.image_library').jscroll
    #debug: true,
    loadingHtml: "<img src='#{imagePath}' />",
    padding: 100,
    nextSelector: nextSelector(),
    pagingSelector: ".paginator",
    callback: (data) ->
      addTileImages data.tileImages
      updateNextPageLink data.nextPageLink
      window.selectImageFromLibrary()