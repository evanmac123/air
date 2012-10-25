 
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  initSlideShow()
  updatePositionFunc(false, start_tile, null)


############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
first_ping_after_load = 1
slideshow = positionElement = imageCount = start_tile = tile_image = 0

# This is a function definition
loadDivs = () ->
  slideshow = $('#slideshow')
  positionElement = $('#position')
  imageCount = $('#slideshow img').length
  start_tile_id = $('#start_tile').text()
  start_tile = $('#' + start_tile_id).index()
  tile_image = $('.tile_image')

initSlideShow = () ->
  if slideshow.length
    if tile_image.length == 1
      tile_image.show()
      resizeSlideshow()
    else
      slideshow.cycle
        startingSlide: start_tile,
        timeout: 0,
        onPrevNextEvent: updatePositionFunc,
        after: callbacksAfterTileTransition,
        next: 'a#next',
        prev: 'a#prev'

updatePositionFunc = (isNext, slideIndex, slideElement) ->
  newContent = "Tile: " + (slideIndex + 1) + " of " + imageCount
  positionElement.html(newContent)

callbacksAfterTileTransition = (currSlideElement, nextSlideElement, options, forwardFlag) -> 
  resizeSlideshow()
  sendViewedTilePing(currSlideElement.id)

sendViewedTilePing = (tile_id) ->
  via = 0
  if (first_ping_after_load)
    via = 'thumbnail'
    first_ping_after_load = 0
  else
    via = 'next_button'
  properties = {via: via, tile_id: tile_id}
  data = {event: "viewed tile", properties: properties}
  $.post('/ping', data)

resizeSlideshow = () -> 
  array_of_images = $('#slideshow img')
  offset = 45
  max_height = 0
  $.map array_of_images, (image) ->
    max_height = image.height if (image.height > max_height)
  slideshow.height(max_height + offset)


