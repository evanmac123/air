//FIXME remove from global namespace and into IIF
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

    $('.status_div').find('.private').on('click', function(event) {
      $('.status_div').find('.switch > #private_button').click();
    });

    $('.status_div').find('.public').on('click', function(event) {
      $('.status_div').find('.switch > #public_button').click();
    });

    $('.status_div').find('.switch').on('click', function(event) {
      var demo_id;
      if ($("#private_button").attr("checked")) {
        demo_id = $('.new_public_board').attr('id');
        $.ajax({
          url: "/client_admin/public_boards/" + demo_id,
          type: 'DELETE'
        });
        $('.status_div').find('.private').addClass('engaged').removeClass('disengaged');
        $('.status_div').find('.public').addClass('disengaged').removeClass('engaged');

        document.getElementById("public_board_field").setAttribute("disabled", "true");
      } else {
        $.post("/client_admin/public_boards");
        $('.status_div').find('.private').addClass('disengaged').removeClass('engaged');
        $('.status_div').find('.public').addClass('engaged').removeClass('disengaged');
        document.getEl;
      }
    });
  });
};
