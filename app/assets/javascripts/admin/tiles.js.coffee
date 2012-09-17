# This is COFFEE SCRIPT :D

  
# This is how you call the stuff that loads when the page is finished loading
$ ->
  loadDivs()
  makeSortable()
  connectHideDetailsDuringSort()  
already_dragged = 0
table = details = anywhere = 0
drag = 0

loadDivs = () ->
  table = $('#tiles_index .sortable_body')
  details = $(".tile_details")
  anywhere = $('body')
  drag = $('#drag')

makeSortable = () ->
  table.sortable(
    axis: 'y',
    # specify which items can be dragged so noone drags the title
    items: '.draggable',
    # use this helper so cells keep their width
    helper: fixHelper,
    # Call this afterward
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      displayRefreshMessage()
  )


# This helper from http://www.foliotek.com/devblog/make-table-rows-sortable-using-jquery-ui-sortable/
# sets the width of the row we're dragging so it doesn't shrink enroute
fixHelper = (e, ui) ->
  ui.children().each ->
    $(this).width($(this).width())
  return ui

connectHideDetailsDuringSort = () ->
  anywhere.mousedown ->
    details.addClass('opaque')
  anywhere.mouseup ->
    details.removeClass('opaque')


displayRefreshMessage = () ->
  unless already_dragged
    already_dragged = 1
    time = 1000
    drag.fadeOut time, -> 
      drag.html('<h3>Refresh to update numbering</h3>')
      drag.fadeIn time 
