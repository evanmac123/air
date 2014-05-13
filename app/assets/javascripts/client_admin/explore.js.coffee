calculateHeight = (all_tile_tags, use_parent_height) ->
  if use_parent_height
    return all_tile_tags.parent().height()
  else
    return all_tile_tags.height()

hideExtraTags = (all_tile_tags, extra_tags_list, max_height, use_parent_height) ->
  children = extra_tags_list.children()
  if use_parent_height
    all_tile_tags_height = all_tile_tags.parent().height()
  else
    all_tile_tags_height = all_tile_tags.height()
  while( all_tile_tags_height <= max_height && children.length > 0)
    children.first().appendTo(all_tile_tags)
    children = extra_tags_list.children()
    all_tile_tags_height = calculateHeight(all_tile_tags, use_parent_height)

  if(all_tile_tags_height > max_height)
    all_tile_tags.children().last().appendTo(extra_tags_list)
    $(all_tile_tags).append("<li class='tile_tag'><a class='extra_tags' href='#'>...</a></li>")
    all_tile_tags_height = calculateHeight(all_tile_tags, use_parent_height)

  #decrease the number of items further, if height constraint is still not met
  if(all_tile_tags_height > max_height)
    all_tile_tags.find('li:nth-last-child(2)').appendTo(extra_tags_list)
    
hideExplorePageExtraTags = () ->
  $('.tile_with_tags').find('.explore_tile > .all_tile_tags').each (index) ->
    extra_tags_list = $(this).siblings('ul.extra_tags_list')
    hideExtraTags($(this), extra_tags_list, 30, false)


$(document).ready ->
   
  $('.tile_tag_bar').find(".tile_tags").each (index) ->
    extra_tags_list = $('.tile_tag_bar').find('ul.extra_tags_list')
    hideExtraTags($(this), extra_tags_list, 40, true)

  hideExplorePageExtraTags()

  $('.tile_with_tags').find('.explore_tile > .all_tile_tags > .tile_tag > .extra_tags').on('click', (event) ->
    $(this).parent().parent().siblings('ul.extra_tags_list').toggle()
    false
  )
  
  #show/hide extended tile tags list on clicking the '...' button in tile_preview page
  $('.tile_tag_bar').find(".extra_tags").on('click', (event) ->
    $('.tile_tag_bar').find('ul.extra_tags_list').toggle()
    false
  )
    
  #show extended tile tags list on clicking the '...' button in explore page
  $('body.explores').on('click', (event) ->
    $(this).find('ul.extra_tags_list').hide()
  )
  #show/hide extended tile tags list on clicking the '...' button in tile preview page
  $('body.tile_previews').on('click', (event) ->
    $(this).find('ul.extra_tags_list').hide()
  )
    
  $('body.explores .copy_tile_link').on('click', (event) ->
    copyButton = $(event.target)
    event.preventDefault()
   
    copyLink = $(this)

    $.post(copyLink.attr('data_url'), {},
      (data) ->
        if(data.success)
          $('#edit_copied_tile_link').attr('href', data.editTilePath)
          $('#tile_copied_reveal').foundation('reveal', 'open')
          copyLink.closest('.not_copied').removeClass('not_copied').addClass('copied')
          copyLink.text('Copied')
          copyMessage = copyLink.parent().find('.copy_message')
          copyMessage.text(data.copyCount)
      ,
      'json'
    )
  )

window.hideExplorePageExtraTags = hideExplorePageExtraTags
