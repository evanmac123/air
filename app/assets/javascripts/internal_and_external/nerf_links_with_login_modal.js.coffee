popLoginModal = (event) ->
  event.preventDefault()
  $('#login_modal').foundation('reveal', 'open')

nerfBySelector = (selector) ->
  $(selector).click(popLoginModal)

nerfLinksWithLoginModal = () ->
  nerfBySelector(selector) for selector in [
    '#board_switch_toggler',
    '#manage_board',
    '#top_bar #logo a',
    '#post_copy_buttons #manage_board_post_copy',
    '#post_copy_buttons #edit_copied_tile_link'
  ]

window.nerfLinksWithLoginModal = nerfLinksWithLoginModal
