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
    # '#post_copy_buttons #manage_board_post_copy',
    # '#post_copy_buttons #edit_copied_tile_link',
    ".sweet-alert .cancel"
    '#top_bar .user_options #my_profile',
    '#top_bar .user_options .nav-settings',
    '#top_bar .user_options .nav-directory',
  ]

window.nerfLinksWithLoginModal = nerfLinksWithLoginModal
