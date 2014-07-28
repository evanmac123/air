function bindBoardSettingsControls() {
  $('#board_settings .board_name').focus(function(event) {
    $(this).closest('.board_wrapper').removeClass('unfocused');
    var demoId = $(this).data('demo_id');
    $('a.save_board_name').hide();
    $('.board_saving').hide();
    $('.board_saved').hide();
    $('a.save_board_name[data-demo_id="' + demoId + '"]').show();
  });

  $('.edit_board_name_link, .edit_board_name_icon').click(function(event) {
    event.preventDefault();
    $(this).closest('.board_wrapper').find('.board_name').focus();
  });

  $('.save_board_name').click(function(event) {
    event.preventDefault();

    var demoId = $(this).data('demo_id');
    var updateURL = "/boards/" + demoId;
    var boardName = $('.board_name[data-demo_id="' + demoId + '"]').text()
    var controlSection = $('.board_save_controls[data-demo_id="' + demoId + '"]');

    controlSection.find('.save_board_name').hide();
    controlSection.find('.board_saving').show();

    $.post(
      updateURL,
      { board_name: boardName,
        _method: 'PUT'
      },
      function(data) {
        controlSection.find('.board_saving').hide();
        if(data.success) {
          controlSection.find('.board_saved').show();
        } else {
          controlSection.find('.board_save_error').text(data.message);
        }
        controlSection.closest('.board_wrapper').addClass('unfocused');
      }
    )
  });

  $('#leave_board_safety_modal input[type="text"]').on('keyup', function(event) {
    var submitButton = $('#leave_board_safety_modal input[type="submit"]');

    if($(event.target).val() == 'DELETE') {
      submitButton.removeAttr('disabled', 'disabled');
    } else {
      submitButton.attr('disabled', 'disabled');
    }
  });

  $('.delete_board_icon').click(function(event) {
    event.preventDefault();

    var deleteURL = $(event.target).data('delete_url');
    $('#leave_board_form').attr('action', deleteURL);
    $('#leave_board_safety_modal').foundation('reveal', 'open');
  });

  $('#close_board_settings').click(function(event) {
    event.preventDefault();
    $('#board_settings').foundation('reveal', 'close');
  });

  $('#close_safety_modal').click(function(event) {
    event.preventDefault();
    $('#leave_board_safety_modal').foundation('reveal', 'close');
  });

  var postMuteRequest = function(elt) {
    var muteURL = elt.data('mute_url');
    var muteStatus = elt.val();
    $.post(muteURL, {_method: 'PUT', status: muteStatus});
  };

  $('.followup_mute, .followup_unmute, .digest_unmute').change(function(event) {
    postMuteRequest($(this));
  });

  $('.digest_mute').change(function(event) {
    $('.followup_mute').click();
    postMuteRequest($(this));
  });
}
