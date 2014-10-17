jumpTagSelected = (event, ui) ->
  if ui.item.value.found
    appendSelectedTags(ui.item.value.id, ui.item.label)
  else
    addNewTag(ui.item.value.name)
  $('#add-tag').val("")
  event.preventDefault()

addNewTag = (name) ->
  $.ajax(
    url: "/client_admin/tile_tags/add?term=#{name}",
    success: (id)->
      appendSelectedTags(id, name)
  )

publicTileForm = ->
  $('#public_tile_form')

tileTagsError = ->
  $('#sharable_tile_link_on').is(':checked') &&
  $('#share_on').is(':checked') &&
  $('.share_options').find('.tile_tags li').length < 1
  
appendSelectedTags = (id, name) ->
  publicTileForm().find('.tag_alert').hide()
  if $('ul.tile_tags > li[id='+id+']').length < 1
    $('ul.tile_tags').append("<li id='#{id}'>#{name}<a class='fa fa-times'></a> </li>")
    if $('#tile_builder_form_tile_tag_ids').val() == ""
      $('#tile_builder_form_tile_tag_ids').val(id)
    else
      $('#tile_builder_form_tile_tag_ids').val($('#tile_builder_form_tile_tag_ids').val() + ",#{id}")
  publicTileForm().submit()
    
initialSetting = ->
  if $('.share_options').find('#share_off').attr('checked')
    $('.share_options').find('.allow_copying').hide()
    $('.share_options').find('.add_tag').hide()
    $('.share_options').hide()
  else if $('.share_options').find('#share_on').attr('checked')
    $('.share_options').find('.allow_copying').show()
    $('.share_options').find('.add_tag').show()
    $('.share_options').show()
  $('#tile_builder_form_tile_tag_ids').hide()

window.bindTagNameSearchAutocomplete = (sourceSelector, targetSelector, searchURL) ->
  $(sourceSelector).autocomplete({
    appendTo: targetSelector, 
    source:   searchURL, 
    html:     'html', 
    select:   jumpTagSelected,
    focus:    (event) -> event.preventDefault()})

  initialSetting()

  $('.share_to_explore').on('click', (event) ->
    if $(this).find('#share_off').attr('checked')
      $('.share_options').find('.allow_copying').hide()
      $('.share_options').find('.add_tag').hide()
    else if $(this).find('#share_on').attr('checked')
      $('.share_options').find('.allow_copying').show()
      $('.share_options').find('.add_tag').show()
  )
  
  $(document).on('click','.add_tag .fa', (event) ->
    element = $(this).parent()
    tag_id = element.attr('id')
    
    vals = $('.share_options').find('#tile_builder_form_tile_tag_ids').val().split ','
    filtered_vals = vals.filter (selected_tag_id) -> selected_tag_id isnt tag_id
    $('.share_options').find('#tile_builder_form_tile_tag_ids').val(filtered_vals.join(','))
    
    element.remove()
    publicTileForm().submit()
  )

  publicTileForm().on('submit', (event) ->
    if $(this).find('#share_on').is(':checked')
      if $(this).find('.share_options').find('.tile_tags li').length < 1
        false
      else
        $(this).find('.tag_alert').hide()
        true
    else
      true
  ) 

  $('#share_off, #share_on, #allow_copying_on, #allow_copying_off').click ->
    publicTileForm().submit()

  $(window).on "beforeunload", ->
    if tileTagsError()
      $('.tag_alert').show()
      "If you leave this page, you’ll lose any changes you made. Please, save them before leaving."

  $("#back_header a, #archive, #post, .edit_header a, .new_tile_header a").click (e)->
    if tileTagsError()
      e.preventDefault()
      e.stopPropagation()
      $('.tag_alert').show()
