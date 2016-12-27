//FIXME remove from global namespace and into IIF and refactor!
window.publicBoardControls = function() {
  $(document).on('keydown keyup keypress', '#public_board_field', function(event) {
    if (!(event.ctrlKey || event.altKey || event.metaKey)) {
      event.preventDefault();
    }
  });

  $(document).on('click', '#public_board_field', function(event) {
    event.preventDefault();
    $(event.target).focus().select();
  });

  return $(document).ready(function() {
    $('#digest_digest_send_to').on('change', function(event) {
      if ($('#digest_digest_send_to option:selected').text() === "All Users") {
        $('#all_users').show();
        $('#activated_users').hide();
      } else if ($('#digest_digest_send_to option:selected').text() === "Activated Users") {
        $('#all_users').hide();
        $('#activated_users').show();
      }
    });

    $('#digest_digest_send_to').trigger('change');
  });
};
