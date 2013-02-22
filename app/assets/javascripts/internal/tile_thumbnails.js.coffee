# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  connectCarousel()
  displayTileThumbnails()
  connectFadeCompletedTiles()

############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
tile_thumbnail = tile_thumbnail_carousel = recent = 0
carousel = 0

# This is a function definition
loadDivs = () ->
  tile_thumbnail_carousel = $('#tile_thumbnail_carousel')
  tile_thumbnail = $('.tile_thumbnail')
  recent = $('.recently_completed')
connectCarousel = () ->
  tile_thumbnail_carousel.jcarousel(
    {}
  )
  carousel = tile_thumbnail_carousel.data("jcarousel");

displayTileThumbnails = () ->
  # These are hidden initially so we don't see them load in a big long line
  tile_thumbnail.show()

connectFadeCompletedTiles = () ->
  recent.css({'border-color': 'black', 'border-thickness': '5px'})
  # $('.recently_completed').effect 'highlight', {color: '#fff'}, 500

  recent.fadeOut 3000, ->
    # They are already hidden, but we now remove them as well so that 
    # we get an accurate count later
    carousel.remove($(this).attr('jcarouselindex'))
    $(this).remove()
    unbindNextArrow() if threeOrLessThumbnails()

   
unbindNextArrow = () ->
  # After completing a task, they should fade out, and if there are less than 
  # four tiles, we disable the "next" arrow
  next = $('.jcarousel-next')
  next_horz = $('.jcarousel-next-horizontal')
  next_horz_hover = $('.jcarousel-next-horizontal:hover')
  what = "background-position"
  where = "-96px 0px"
  next.off()
  next.css("cursor", "default")
  next_horz.css(what, where)
  next_horz_hover.css(what, where)

threeOrLessThumbnails = () ->
  # Note this is not using the variable version of tile_thumbnail, because
  # if it uses that, the length is not recalculated dynamically
  $('.tile_thumbnail').length < 4

