jumpTagSelected = (event, ui) ->
  if ui.item.value.found
    appendSelectedTags(ui.item.value.id, ui.item.label)
  else
    addNewTag(ui.item.value.name)
  $('#add-tag').val("")
  event.preventDefault()

addNewTag = (name) ->
  $.ajax(
    url: "/client_admin/tile_tags/add?tag_name=#{name}",
    success: (data)-> 
      appendSelectedTags(data, name)
  )
  
appendSelectedTags = (id, name) ->
  $('.tile_tags').append("<li id='#{id}'>#{name}<a class='fa fa-times'></a> </li>")
  if $('#tile_builder_form_tile_tag_ids').val() == ""
    $('#tile_builder_form_tile_tag_ids').val(id)
  else
    $('#tile_builder_form_tile_tag_ids').val($('#tile_builder_form_tile_tag_ids').val() + ",#{id}")
  
window.bindTagNameSearchAutocomplete = (sourceSelector, targetSelector, searchURL) ->
  $(sourceSelector).autocomplete({
    appendTo: targetSelector, 
    source:   searchURL, 
    html:     'html', 
    select:   jumpTagSelected,
    focus:    (event) -> event.preventDefault()})


$(document).ready ->
  if $('.share_explore').find('#share_off').attr('checked')
    $('.allow_copying').hide()
    $('.add_tag').hide()
  else if $(this).find('#share_on').attr('checked')
    $('.allow_copying').show()
    $('.add_tag').show()
  
  $('#tile_builder_form_tile_tag_ids').hide()
  $('#tile_builder_form_tile_tag_ids').val("")
  $('.share_explore').on('click', (event) ->
    if $(this).find('#share_off').attr('checked')
      $('.allow_copying').hide()
      $('.add_tag').hide()
    else if $(this).find('#share_on').attr('checked')
      $('.allow_copying').show()
      $('.add_tag').show()
  )
  
  $(document).on('click','.add_tag .fa', (event) ->
    element = $(this).parent()
    tag_id = element.attr('id')
    
    vals = $('#tile_builder_form_tile_tag_ids').val().split ','
    filtered_vals = vals.filter (selected_tag_id) -> selected_tag_id isnt tag_id
    $('#tile_builder_form_tile_tag_ids').val(filtered_vals.join(','))
    
    element.remove()
  )
  
  $('#new_tile_builder_form').on('submit', (event) ->
    if $(this).find('#share_on').is(':checked')
      if $(this).find('.share_options').find('.tile_tags li').length < 1
        $(this).find('.tag_alert').show()
        $(this).find('#submit_spinner').hide()
        false
      else
        $(this).find('.tag_alert').hide()
        true
  )   