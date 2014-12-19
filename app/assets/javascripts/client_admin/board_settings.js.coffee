String.prototype.trimToLength = (m) ->
  if this.length > m
    jQuery.trim(this).substring(0, m).trim(this) + "...";
  else
    this

initialSetUp = (field) ->
  setOldValue field
  bindClearLinkAndField field
  addCharacterCounterFor field

bindClearLinkAndField = (field) ->
  form = findForm field
  clear_link = form.find(".clear_form")
  clear_link.data "selector", field.attr("id")

setOldValue = (field) ->
  field.data "old-value", field.val()

oldValue = (field) ->
  field.data("old-value")

errorMess = (form) ->
  form.find(".error_message")

updateCurrentBoardName = (new_name) ->
  $("#current_board_name").text new_name.trimToLength(12)

formResponse = (form) ->
  (data) ->
    submit = findSubmit(form)
    submit.val "Update"
    if data.success
      form.removeClass("dirty").removeClass("has_error")
      submit.prop('disabled', true)
      field = form.find("input[type='text']")
      setOldValue field
      updateCurrentBoardName field.val()
    else
      form.addClass("has_error")

findSubmit = (form) ->
  form.find("input[type='submit']")

findForm = (field) ->
  field.closest("form")

window.boardNameForm = ->
  initialSetUp $("#demo_name")

  $("#demo_name").focusin ->
    form = findForm $(@)
    form.addClass("active")

    unless oldValue $(@)
      setOldValue $(@)

    unless form.hasClass("dirty")
      submit = findSubmit(form)
      submit.prop('disabled', true)

  $("#demo_name").focusout ->
    form = findForm $(@)
    form.removeClass("active")

  $("#demo_name").on 'input propertychange paste', ->
    form = findForm $(@)
    form.addClass("dirty")

    submit = findSubmit(form)
    submit.prop('disabled', false)

    if $("#demo_name").data("old-value") == $("#demo_name").val()
      form.removeClass("dirty")
      submit.prop('disabled', true)

  $(".clear_form").click ->
    field = $( "#" + $(@).data('selector') )
    field.val oldValue(field)
    form = findForm field
    form.removeClass("dirty").removeClass("has_error")
    submit = findSubmit(form)
    submit.prop('disabled', true)

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
