# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  connectCarousel()
  connectFadeCompletedTiles()

############# find a way to only include this once ###########
delay = (ms, func) -> setTimeout func, ms
####################################################

# This is me setting all variables in the local scope so I can use them later
tile_thumbnail_carousel = recent = 0

# This is a function definition
loadDivs = () ->
  tile_thumbnail_carousel = $('#tile_thumbnail_carousel')
  recent = $('.recently_completed')
connectCarousel = () ->
  tile_thumbnail_carousel.jcarousel(
    {}
  )

connectFadeCompletedTiles = () ->
  recent.css({'border-color': 'black', 'border-thickness': '5px'})
  # $('.recently_completed').effect 'highlight', {color: '#fff'}, 500
  recent.fadeOut 3000, ->
    $(this).remove()
