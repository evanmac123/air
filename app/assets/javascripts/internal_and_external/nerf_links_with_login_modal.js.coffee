popLoginModal = (event) ->
  event.preventDefault()
  $('#login_modal').foundation('reveal', 'open')

nerfBySelector = (selector) ->
  $(selector).click(popLoginModal)

nerfLinksWithLoginModal = () ->
  nerfBySelector(selector) for selector in [
    '#board_switch_toggler',
    '#manage_board'
  ]

window.nerfLinksWithLoginModal = nerfLinksWithLoginModal
