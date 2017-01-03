var nerfBySelector, nerfLinksWithLoginModal, popLoginModal;

popLoginModal = function(event) {
  var loginModal, originalLink;
  event.preventDefault();
  originalLink = $(event.target);
  loginModal = $('#login_modal');
  loginModal.find('#url_after_create').val(originalLink.attr('href'));
  return loginModal.foundation('reveal', 'open');
};

nerfBySelector = function(selector) {
  return $(document).on('click', selector, popLoginModal);
};

nerfLinksWithLoginModal = function() {
  var i, len, ref, results, selector;
  $('#login_modal').bind('opened', function() {
    return $('#session_password').focus();
  });
  ref = ['#board_switch_toggler', '#board_settings_toggle', '#manage_board', '#top_bar #logo a', ".sweet-alert.tile_copied_lightbox .cancel", '#top_bar .user_options #my_profile', '#top_bar .user_options .nav-settings', '#top_bar .user_options .nav-directory'];
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    selector = ref[i];
    results.push(nerfBySelector(selector));
  }
  return results;
};

window.nerfLinksWithLoginModal = nerfLinksWithLoginModal;
