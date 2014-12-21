String.prototype.trimToLength = (m) ->
  if this.length > m
    jQuery.trim(this).substring(0, m).trim(this) + "...";
  else
    this

#isTextField = (field) ->
#  field.attr("type") == "text"

oldValue = (field) ->
  field.data("old-value")

setOldValue = (field) ->
  field.data "old-value", field.val()

bindClearLinkAndField = (field) ->
  form = findForm field
  clear_link = form.find(".clear_form")
  clear_link.data "selector", field.attr("id")

initialSetUp = (field) ->
  setOldValue field
  bindClearLinkAndField field

findSubmit = (form) ->
  form.find("input[type='submit']")

findForm = (field) ->
  field.closest("form")

findField = (form) ->
  clear_link = form.find(".clear_form")
  connectedField(clear_link)

disableSubmit = (form, disabled) ->
  submit = findSubmit(form)
  submit.prop('disabled', disabled)

connectedField = (clear_link) ->
  $( "#" + clear_link.data('selector') )

fieldHasInitialValue = (field) ->
  field.data("old-value") == field.val()

updateCurrentBoardName = (field) ->
  newName = field.val()
  $("#current_board_name").text newName.trimToLength(12)

tableOfSpecificFormResponses = () ->
  demo_name: updateCurrentBoardName

specificFormResponse = (field) ->
  fieldSelector = field.attr("id")
  func = tableOfSpecificFormResponses()[fieldSelector]
  unless func
    func(field)

formResponse = (form) ->
  (data) ->
    submit = findSubmit(form)
    submit.val "Update"
    if data.success
      form.removeClass("dirty").removeClass("has_error")
      disableSubmit(form, true)

      field = findField(form)
      setOldValue field

      specificFormResponse(field)
    else
      form.addClass("has_error")

window.formWithClearableTextField = (fieldSelector) ->
  field = $(fieldSelector)
  initialSetUp field
  #
  # => Field Events
  #
  field.focusin ->
    form = findForm $(@)
    form.addClass("active")

    unless oldValue $(@)
      setOldValue $(@)

    unless form.hasClass("dirty")
      disableSubmit(form, true)

  field.focusout ->
    form = findForm $(@)
    form.removeClass("active")

  field.on 'input propertychange paste', ->
    form = findForm $(@)
    form.addClass("dirty")

    disableSubmit(form, false)

    if fieldHasInitialValue $(@) 
      form.removeClass("dirty")
      disableSubmit(form, true)
  #
  # => Clear Link
  #
  findForm(field).find(".clear_form").click ->
    field = connectedField $(@)
    field.val oldValue(field)

    form = findForm field
    form.removeClass("dirty").removeClass("has_error")

    disableSubmit(form, true)
  #
  # => Submit Form Event
  #
  findForm(field).submit (e) ->
    e.preventDefault()
    submit = findSubmit $(@)
    submit.val "Updating..."

    $.ajax 
      type: "POST"
      url: $(@).attr "action"
      data: $(@).serialize()
      success: formResponse( $(@) )
      dataType: "json"


