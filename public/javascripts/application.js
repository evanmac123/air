$(function() {
  $('#add-new-player').live('click', function() {
    $('#new_player').parent('.hidden-form').show();
    $('#player_name').focus();
    return false;
  });
});
