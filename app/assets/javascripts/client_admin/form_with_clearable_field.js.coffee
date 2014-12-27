String.prototype.trimToLength = (m) ->
  if this.length > m
    jQuery.trim(this).substring(0, m).trim(this) + "...";
  else
    this

oldValue = (field) ->
  field.data("old-value")

setOldValue = (field) ->
  field.data "old-value", field.val()

updateOldValue = (field) ->
  return unless field.data("old-value")
  setOldValue field

bindClearLinkAndField = (field) ->
  form = findForm field
  clear_link = form.find(".clear_form")
  clear_link.data "selector", field.attr("id")

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
  return false unless field.data("old-value")
  field.data("old-value") == field.val()

updateCurrentBoardName = (field, data) ->
  newName = field.val()
  $("#current_board_name").text newName.trimToLength(12)

updateLogo = (field, data) ->
  $("#logo a img").attr("src", data.logo_url)
  form = findForm field
  form[0].reset()

tableOfSpecificFormResponses = () ->
  demo_name: updateCurrentBoardName
  demo_logo: updateLogo

specificFormResponse = (field, data) ->
  fieldSelector = field.attr("id")
  func = tableOfSpecificFormResponses()[fieldSelector]
  if func
    func(field, data)

formResponse = (form) ->
  (data) ->
    submit = findSubmit(form)
    submit.val "Update"

    if data.success
      form.removeClass("dirty").removeClass("has_error")
      disableSubmit(form, true)

      field = findField(form)
      updateOldValue(field) 

      specificFormResponse(field, data)
    else
      form.addClass("has_error")

fieldEvents = (field) ->
  field.on 'input propertychange change paste', ->
    form = findForm $(@)
    form.addClass("dirty")

    disableSubmit(form, false)

    if fieldHasInitialValue $(@) 
      form.removeClass("dirty")
      disableSubmit(form, true)

submitForm = (form) ->
  submit = findSubmit form
  submit.val "Updating..."

  form.ajaxSubmit
    success: formResponse form
    dataType: 'json'

submitEmptyForm = (form) ->
  submit = findSubmit form
  submit.val "Updating..."

  $.ajax
    type: "PUT"
    url: form.attr("action")
    success: formResponse form
    dataType: 'json'

formSubmitHandler = (field) ->
  findForm(field).submit (e) ->
    e.preventDefault()
    submitForm $(@)

window.formWithClearableTextField = (fieldSelector) ->
  field = $(fieldSelector)
  setOldValue field
  bindClearLinkAndField field

  fieldEvents field
  formSubmitHandler field

  findForm(field).find(".clear_form").click ->
    field = connectedField $(@)
    field.val oldValue(field)

    form = findForm field
    form.removeClass("dirty").removeClass("has_error")

    disableSubmit(form, true)

window.formWithClearableLogoField = (fieldSelector, old_ie) ->
  field = $(fieldSelector)
  bindClearLinkAndField field
  fieldEvents field
  unless old_ie
    formSubmitHandler field

  findForm(field).find(".clear_form").click ->
    field = connectedField $(@)
    form = $(@).closest("form")

    if field.val().length > 0 
      form[0].reset()
      form.removeClass("dirty").removeClass("has_error")
    else
      # remove logo
      submitEmptyForm(form)

window.urlField = (fieldSelector) ->
  field = $(fieldSelector)
  field.on 'input propertychange change paste', ->
    $(@).val $(@).val().toLowerCase().replace /\s/g, "-"
      
