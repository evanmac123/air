popLoginModal = (event) ->
  event.preventDefault()

  originalLink = $(event.target)
  loginModal = $('#login_modal')

  loginModal.find('#url_after_create').val(originalLink.attr('href'))

  loginModal.foundation('reveal', 'open')

nerfBySelector = (selector) ->
  $(document).on('click', selector, popLoginModal)

nerfLinksWithLoginModal = () ->
  $('#login_modal').bind('opened', () -> $('#session_password').focus())

  nerfBySelector(selector) for selector in [
    '#board_switch_toggler',
    '#board_settings_toggle',
    '#manage_board',
    '#top_bar #logo a',
    ".sweet-alert.tile_copied_lightbox .cancel"
    '#top_bar .user_options #my_profile',
    '#top_bar .user_options .nav-settings',
    '#top_bar .user_options .nav-directory',
  ]

window.nerfLinksWithLoginModal = nerfLinksWithLoginModal
