window.boardSettingsPage = ->
  updateTooltipCounter = (counter) ->
    tooltipCounter = $("#boards_name_chars_left")
    if tooltipCounter.length == 0
      $("#board_name_tooltip").trigger('mouseenter').trigger('mouseleave')
      tooltipCounter = $("#boards_name_chars_left")
    chars_num = parseInt counter.text()
    tooltipCounter.text chars_num
      

  initialSetUp = (field) ->
    setOldValue field
    addClearLink field
    addCharacterCounterFor field
    updateTooltipCounter $("#edit_board_name .character-counter")

  addClearLink = (field) ->
    form = field.closest("form")
    submit = form.find("input[type='submit']")
    clear_link = $( clearLinkHTML() )
    clear_link.attr "data-selector", field.attr("id")
    submit.after clear_link 

  clearLinkHTML = ->
    '<div class="clear_form">Clear</div>'

  setOldValue = (field) ->
    field.attr "old-value", field.val()

  oldValue = (field) ->
    field.attr("old-value")

  initialSetUp $("#demo_name")

  $("#demo_name").focusin ->
    form = $(@).closest("form")
    form.addClass("active")

    unless oldValue $(@)
      setOldValue $(@)

    unless form.hasClass("dirty")
      submit = form.find("input[type='submit']")
      submit.prop('disabled', true)

  $("#demo_name").focusout ->
    form = $(@).closest("form")
    form.removeClass("active")

  $("#demo_name").on 'input propertychange paste', ->
    form = $(@).closest("form")
    form.addClass("dirty")

    submit = form.find("input[type='submit']")
    submit.prop('disabled', false)

    if $("#demo_name").attr("old-value") == $("#demo_name").val()
      form.removeClass("dirty")
      submit.prop('disabled', true)

  $(".clear_form").click ->
    field = $( "#" + $(@).attr('data-selector') )
    field.val oldValue(field)
    form = field.closest("form")
    form.removeClass("dirty").removeClass("has_error")
    submit = form.find("input[type='submit']")
    submit.prop('disabled', true)

  $("#edit_board_name .character-counter").bind "DOMNodeInserted",  ->
    updateTooltipCounter $(@)

  errorMess = (form) ->
    form.find(".error_message")

  formResponse = (form) ->
    (data) ->
      submit = form.find("input[type='submit']")
      submit.val "Update"
      if data.success
        #errorMess(form).hide()
        form.removeClass("dirty").removeClass("has_error")
        submit.prop('disabled', true)
      else
        form.addClass("has_error")
        #errorMess(form).show()
        #submit = form.find("input[type='submit']")
        #submit.before


  $("form").submit (e) ->
    e.preventDefault()
    submit = $(@).find("input[type='submit']")
    submit.val "Updating..."

    $.ajax 
      type: "POST"
      url: $(@).attr "action"
      data: $(@).serialize()
      success: formResponse( $(@) )
      dataType: "json"
