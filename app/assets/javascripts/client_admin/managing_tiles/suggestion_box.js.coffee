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
  $('#cancel_suggestion_box')

userRow = (userId) ->
  $("#allowed_to_suggest_user_" + userId)

usersTableBody = ->
  $("#allowed_to_suggest_users tbody")

searchInput = ->
  $("#name_substring")

searchResultsSelector = ->
  "#name_autocomplete_target"

window.suggestionBox = ->
  #
  # => Suggestion Switcher
  #
  showSection = (section) ->
    if section == 'allUsers'
      allUsers().slideDown()
      specificUsers().slideUp()
    else
      allUsers().slideUp()
      specificUsers().slideDown()
    formChanged()

  switherOn().click (e) ->
    showSection('allUsers')

  switherOff().click (e) ->
    showSection('specificUsers')
  #
  # => Suggestion Box Modal
  #
  blockSaveBtn = ->
    saveBtn().attr("disabled", "disabled")
    window.needToBeSaved = false

  unblockSaveBtn = ->
    saveBtn().removeAttr("disabled")
    window.needToBeSaved = true

  triggerModal = (action) ->
    modal().foundation('reveal', action)

  $(document).on 'open.fndtn.reveal', modalSelector(), ->
    blockSaveBtn()

  manageAccessBtn().click (e)->
    e.preventDefault()
    triggerModal('open')

  cancelBtn().click (e)->
    e.preventDefault()
    triggerModal('close')
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
  formChanged = ->
    unblockSaveBtn()
  #
  # => Initialization
  #
  triggerModal('open')