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