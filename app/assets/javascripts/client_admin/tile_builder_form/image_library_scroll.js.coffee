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
    # i had to rewrite this plugin (only part with request and callback)
    # so now it works this way:
    # plugin uses link from nextSelector, makes request,
    # calls this callback and gives data from the response and
    # update its own variable with link from nextSelector if it was changed.
    callback: (data) ->
      addTileImages data.tileImages
      updateNextPageLink data.nextPageLink
      window.selectImageFromLibrary()