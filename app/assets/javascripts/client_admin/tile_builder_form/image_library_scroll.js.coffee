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

window.imageLibraryScroll = ->
  $('.image_library').jscroll
    debug: true,
    loadingHtml: '<p>Loading...</p>',
    padding: 20,
    nextSelector: nextSelector(),
    pagingSelector: ".paginator",
    callback: (data) ->
      console.log data
      addTileImages data.tileImages
      updateNextPageLink data.nextPageLink