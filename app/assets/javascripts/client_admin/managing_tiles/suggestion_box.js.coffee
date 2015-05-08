showSection = (section) ->
  if section == 'allUsers'
    $(".all_users_section").slideDown()
    $('.specific_users_section').slideUp()
  else
    $(".all_users_section").slideUp()
    $('.specific_users_section').slideDown()

window.suggestionBox = ->
  $('#suggestion_box_modal').foundation('reveal', 'open')

  $('#suggestion_switcher_on').click (e) ->
    showSection('allUsers')

  $('#suggestion_switcher_off').click (e) ->
    showSection('specificUsers')
  #
  # => Suggestion Box Modal
  #
  $('.manage_access').click (e)->
    e.preventDefault()
    $('#suggestion_box_modal').foundation('reveal', 'open')

  $('#cancel_suggestion_box').click (e)->
    e.preventDefault()
    $('#suggestion_box_modal').foundation('reveal', 'close')
  #
  # => User Search Autocomplete
  #
  alreadyInList = (userId) ->
    $("#allowed_to_suggest_user_" + userId).length > 0

  getSelectedUser = (e, ui) ->
    e.preventDefault()
    if ui.item.value.found && !alreadyInList(ui.item.value.id)
      $.ajax
        type: 'GET',
        url: '/client_admin/allowed_to_suggest_users/' + ui.item.value.id
        success: (data) ->
          $("#allowed_to_suggest_users tbody").prepend data.userRow
    else
      $("#name_substring").val('').focus()

  $("#name_substring").autocomplete
    appendTo: "#name_autocomplete_target", 
    source:   '/client_admin/users', 
    html:     'html', 
    select:   getSelectedUser,
    focus:    (e) -> e.preventDefault()