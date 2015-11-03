(($, undefined_) ->
  $.fn.getCursorPosition = ->
    el = $(this).get(0)
    pos = 0
    if "selectionStart" of el
      pos = el.selectionStart
    else if "selection" of document
      el.focus()
      Sel = document.selection.createRange()
      SelLength = document.selection.createRange().text.length
      Sel.moveStart "character", -el.value.length
      pos = Sel.text.length - SelLength
    pos

  $.fn.setCursorPosition = (pos) ->
    @each (index, elem) ->
      if elem.setSelectionRange
        elem.setSelectionRange pos, pos
      else if elem.createTextRange
        range = elem.createTextRange()
        range.collapse true
        range.moveEnd "character", pos
        range.moveStart "character", pos
        range.select()
      return

    this

  return
) jQuery

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

updateCoverImage = (field, data) ->
  $("#cover_image").attr("src", data.logo_url)
  form = findForm field
  form[0].reset()

tableOfSpecificFormResponses = () ->
  demo_name: updateCurrentBoardName
  demo_logo: updateLogo
  demo_cover_image: updateCoverImage

specificFormResponse = (field, data) ->
  fieldSelector = field.attr("id")
  func = tableOfSpecificFormResponses()[fieldSelector]
  if func
    func(field, data)

hasEmptyErrorMess = (form) ->
  form.find(".empty_error_message").length > 0

showEmptyErrorMess = (form) ->
  field = findField(form)
  if hasEmptyErrorMess(form) && field.val().length == 0
    form.addClass("has_empty_error")
    field.val oldValue(field)
  else
    form.removeClass("has_empty_error")

showErrorMess = (form) ->
  form.addClass("has_error")
  showEmptyErrorMess(form)

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
      showErrorMess(form)

fieldEvents = (field) ->
  field.on 'input propertychange change paste keyup', ->
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

removeLogo = (form) ->
  submitEmptyForm(form)

formSubmitHandler = (field) ->
  findForm(field).submit (e) ->
    e.preventDefault()
    submitForm $(@)

lowerCaseField = (field) ->
  field.val field.val().toLowerCase()

replaceSpacesInField = (field, replacer) ->
  field.val field.val().replace /\s/g, replacer

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
      removeLogo(form)

window.urlField = (fieldSelector) ->
  field = $(fieldSelector)

  field.on 'input propertychange change paste keyup', ->
    cursorPos = $(@).getCursorPosition()

    lowerCaseField $(@)
    replaceSpacesInField $(@), "-"

    $(@).setCursorPosition cursorPos
