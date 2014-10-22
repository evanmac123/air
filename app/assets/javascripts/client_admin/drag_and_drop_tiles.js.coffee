window.dragAndDropTiles = ->
  $( "#draft" ).sortable({ connectWith: ".draft-active" })
  $( "#active" ).sortable({ connectWith: ".draft-active, .active-archive" })
  $( "#archive" ).sortable({ connectWith: ".active-archive" })
  $( "#draft, #active, #archive" ).sortable({
    items: ".tile_container:not(.placeholder_container)",
    revert: true,
    update: (event, ui) ->
      id = ui.item.find(".tile_thumbnail").data("tile_id")
      left_tile_id = ui.item.prev().find(".tile_thumbnail").data("tile_id")
      right_tile_id = ui.item.next().find(".tile_thumbnail").data("tile_id")
      status = ui.item.closest(".manage_section").attr("id")
      $.ajax({
        data: {
          left_tile_id: left_tile_id, 
          right_tile_id: right_tile_id,
          status: status
        },
        type: 'POST',
        url: '/client_admin/tiles/' + id + '/sort'
      });
    #over: (event, ui) ->
    #  status = $(this).closest(".manage_section").attr("id")
    #  console.log(status)
    #  if status == "draft"
    #    $(".draft_overlay").show()
        #$("#draft").sortable("disable")
        #$(this).sortable("refresh")
    #out: (event, ui) ->
    #  status = $(this).closest(".manage_section").attr("id")
    #  console.log(status)
    #  if status == "draft"
    #    $(".draft_overlay").hide()
    start: (event, ui) ->
      status = ui.item.closest(".manage_section").attr("id")
      completions = ui.item.find(".completions a").text()
      if status == "active" && completions != "0 users"
        $(".draft_overlay").show()
        $("#draft").sortable("disable")
        $(this).sortable("refresh")
      #$("#draft").on "mouseenter", ->
      #  $(".draft_overlay").show()
      #$("#draft").sortable("disable")
      #$(this).sortable("refresh")
      #$("#draft").mouseout ->
      #  $(".draft_overlay").hide()
    stop: (event, ui) ->
      $(".draft_overlay").hide()
      $("#draft").sortable("enable")
      $(this).sortable("refresh")
    #  $("#draft").sortable("enable")
    #  $(this).sortable("refresh")
    #  $(".draft_overlay").hide()
  }).disableSelection();