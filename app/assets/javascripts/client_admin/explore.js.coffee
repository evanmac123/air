extra_tags = []

$(document).ready ->
  index=0
  extra_tags = new Array($('.all_tile_tags').length)
  while index < extra_tags.length
    extra_tags[index] = new Array(0)
    index++
    
  $(".all_tile_tags").each (index) ->
    while( $(this).children().text().length > 50 )      
      extra_tags[index].push( $(this).children().last().text())
      $(this).siblings('ul').append("<li>#{$(this).children().last().text()}</li>")
      $(this).children().last().remove()      
    if (extra_tags[index].length > 0)
      $(this).append("<a class='tile_tags extra_tags' href='#'>...</a>")
      
  $(".extra_tags").on('click', (event) ->
    $(this).parent().siblings('ul').toggle()
    false
  )