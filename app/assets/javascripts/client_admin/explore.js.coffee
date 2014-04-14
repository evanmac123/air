$(document).ready ->
  extra_tags = []
  
  calculateHeight = (all_tile_tags, use_parent_height) ->
    if use_parent_height
      return all_tile_tags.parent().height()
    else
      return all_tile_tags.height()
    
  hideExtraTags = (all_tile_tags, max_height, use_parent_height) ->
    extra_tags_lists = all_tile_tags.siblings('ul.extra_tags_list')
    
    children = extra_tags_lists.children()
    if use_parent_height
      all_tile_tags_height = all_tile_tags.parent().height()
    else
      all_tile_tags_height = all_tile_tags.height()
    while( all_tile_tags_height <= max_height && children.length > 0)      
      children.first().appendTo(all_tile_tags)
      children = extra_tags_lists.children()
      all_tile_tags_height = calculateHeight(all_tile_tags, use_parent_height)

    if(all_tile_tags_height > max_height) 
      all_tile_tags.children().last().appendTo(extra_tags_lists)
      $(all_tile_tags).append("<li class='tile_tag'><a class='extra_tags' href='#'>...</a></li>")
      all_tile_tags_height = calculateHeight(all_tile_tags, use_parent_height)

    #decrease the number of items further, if height constraint is still not met
    if(all_tile_tags_height > max_height)
      all_tile_tags.find('li:nth-last-child(2)').appendTo(extra_tags_lists)
    
  $('.tile_preview_navbar').find(".all_tile_tags").each (index) ->
    hideExtraTags($(this), 60, true)
  
  $('.tile_with_tags').find('.explore_tile > .all_tile_tags').each (index) ->
    hideExtraTags($(this), 60, false)
    
  $('.tile_with_tags').find('.explore_tile > .all_tile_tags > .tile_tag > .extra_tags').on('click', (event) ->
    $(this).parent().parent().siblings('ul.extra_tags_list').toggle()
    false
  )
  
  $('.tile_preview_navbar').find(".extra_tags").on('click', (event) ->
    $(this).parent().parent().siblings('ul').toggle()
    false
  )
    
  $('body.explores').on('click', (event) -> 
    $(this).find('ul.extra_tags_list').hide()
  )