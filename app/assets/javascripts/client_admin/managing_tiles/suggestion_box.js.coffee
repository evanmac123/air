#
# => Selectors
#
allUsers = ->
  $(".all_users_section")

specificUsers = ->
  $(".specific_users_section")

switherOn = ->
  $('#suggestion_switcher_on')

switherOff = ->
  $('#suggestion_switcher_off')

modalSelector = ->
  '#suggestion_box_modal'

modal = ->
  $(modalSelector())

manageAccessBtn = ->
  $('.manage_access')

saveBtn = ->
  $("#save_suggestion_box")

cancelBtn = ->
  $('#cancel_suggestion_box, #suggestion_box_modal .close-reveal-modal')

userRow = (userId) ->
  $(".allowed_to_suggest_user[data-user-id=#{userId}]")

usersTableBody = ->
  $("#allowed_to_suggest_users tbody")

searchInput = ->
  $("#name_substring")

searchResultsSelector = ->
  "#name_autocomplete_target"

form = ->
  $("#suggestion_box_form")

removeLink = ->
  $(".user_remove a")

warningModalSelector = ->
  "#suggestion_box_warning_modal"

warningModal = ->
  $(warningModalSelector())

warningConfirm = ->
  $(warningModalSelector() + " .confirm")

warningCancel = ->
  $(warningModalSelector() + " .cancel, " + 
    warningModalSelector() + " .close-reveal-modal")

window.suggestionBox = (withModalEvents = true) ->
  #
  # => Suggestion Box Modal
  #
  triggerModal = (action) ->
    modal().foundation('reveal', action)

  cancelBtn().click (e) ->
    e.preventDefault()
    triggerModal('close')
      

  if withModalEvents
    $(document).on 'open.fndtn.reveal', modalSelector(), ->
      unless window.needToBeSaved
        blockSaveBtn()

    $(document).on 'closed.fndtn.reveal', modalSelector(), ->
      if window.needToBeSaved
        triggerWarningModal('open')

    manageAccessBtn().click (e) ->
      e.preventDefault()
      triggerModal('open')
  #
  # => Warning Modal
  #
  triggerWarningModal = (action) ->
    warningModal().foundation('reveal', action)

  if withModalEvents
    warningCancel().click (e) ->
      triggerWarningModal('close')
      
    warningConfirm().click (e) ->
      window.needToBeSaved = 'reload'
      triggerWarningModal('close')
      

    $(document).on 'closed.fndtn.reveal', warningModalSelector(), ->
      if window.needToBeSaved == 'reload'
        reloadForm()
      else
        triggerModal('open')

  #
  # => Suggestion Switcher
  #
  higlightSwitcherCopy = (name) ->
    $(".specific_users, .all_users").removeClass("on")
    if name == 'allUsers'
      $(".all_users").addClass("on")
    else
      $(".specific_users").addClass("on")

  showSection = (name) ->
    if name == 'allUsers'
      allUsers().slideDown()
      specificUsers().slideUp()
    else
      allUsers().slideUp()
      specificUsers().slideDown()
    higlightSwitcherCopy(name)
    formChanged()

  switherOn().click (e) ->
    showSection('allUsers')

  switherOff().click (e) ->
    showSection('specificUsers')
  #
  # => User Search Autocomplete
  #
  alreadyInList = (userId) ->
    userRow(userId).length > 0

  getSelectedUser = (e, ui) ->
    e.preventDefault()
    user = ui.item.value
    if user.found && !alreadyInList(user.id)
      $.ajax
        type: 'GET',
        url: '/client_admin/allowed_to_suggest_users/' + user.id
        success: (data) ->
          usersTableBody().prepend data.userRow
          formChanged()
    else
      searchInput().val('').focus()

  searchInput().autocomplete
    appendTo: searchResultsSelector(), 
    source:   '/client_admin/users', 
    html:     'html', 
    select:   getSelectedUser,
    focus:    (e) -> e.preventDefault()
  #
  # => Suggestion Form
  #
  blockSaveBtn = ->
    saveBtn().attr("disabled", "disabled")
    window.needToBeSaved = false

  unblockSaveBtn = ->
    saveBtn().removeAttr("disabled")
    window.needToBeSaved = true

  formChanged = ->
    unblockSaveBtn()

  reloadForm = ->
    $.ajax
      type: 'GET',
      url: '/client_admin/suggestion_box'
      success: (data) ->
        form().replaceWith data.form
        window.needToBeSaved = false
        window.suggestionBox(false)

  removeLink().click (e) ->
    e.preventDefault()
    $(@).closest("tr").remove()
    formChanged()

  form().on 'submit', (e) ->
    e.preventDefault()
    $(@).ajaxSubmit
      dataType: 'json'
    blockSaveBtn()

  $(window).on "beforeunload", ->
    if window.needToBeSaved
      "You haven't saved your changes."
  #
  # => Initialization
  #
  #triggerModal('open')