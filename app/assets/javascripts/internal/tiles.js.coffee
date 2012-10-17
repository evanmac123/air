 
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  initSlideShow()
  updatePositionFunc(false, start_tile, null)
  displayTileThumbnails()


############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
first_ping_after_load = 1
slideshow = positionElement = imageCount = start_tile = 0

# This is a function definition
loadDivs = () ->
  slideshow = $('#slideshow')
  positionElement = $('#position')
  imageCount = $('#slideshow img').length
  start_tile = parseInt($('#start_tile').text())

displayTileThumbnails = () ->
  # These are hidden initially so we don't see them load in a big long line
  $('.tile_thumbnail').show()

initSlideShow = () ->
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
  current_image = $('#slideshow img:visible')
  current_image_height = current_image.height()
  offset = 45
  slideshow.height(current_image_height + offset)


