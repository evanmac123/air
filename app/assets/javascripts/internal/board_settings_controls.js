function bindBoardSettingsControls() {
  $('#board_settings .board_name').focus(function(event) {
    $(this).closest('.board_wrapper').removeClass('unfocused');
    var demoId = $(this).data('demo_id');
    $('a.save_board_name').hide();
    $('.board_saving').hide();
    $('.board_saved').hide();
    $('a.save_board_name[data-demo_id="' + demoId + '"]').show();
  });

  $('#board_settings').on('opened', function(event) {
    $(event.target).find('.board_wrapper').not('.dirty').each(function(_index, board_wrapper) {
      $(board_wrapper).find('a.save_board_name').hide();
    });
  });

  $('#board_settings .board_name').keypress(function(event) {
    $(event.target).closest('.board_wrapper').addClass('dirty');
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
    var boardSwitchLink = $('header .other_boards #board-switch-link-' + demoId);
    var currentBoardName = $('#board_switch #current_board_name[data-demo-id=' + demoId + ']');

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
          boardSwitchLink.text(data.updatedBoardName);
          currentBoardName.text(data.truncatedUpdatedBoardName);
        } else {
          controlSection.find('.board_save_error').text(data.message);
        }
        controlSection.closest('.board_wrapper').addClass('unfocused');
      }
    )
  });

  $('#leave_board_safety_modal').on('opened', function(event) {
    var textField = $(this).find('input[type=text]');
    textField.val('');
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
    var muteURL = elt.data('mute-url');
    var muteStatus = elt.val();
    $.post(muteURL, {_method: 'PUT', status: muteStatus});
  };

  $('.followup_mute, .followup_unmute').change(function(event) {
    postMuteRequest($(this));
  });

  var relatedSelector = function(selector, boardID) {
    return([selector, '[data-board-id=', boardID, ']'].join(''));
  }

  var relatedFollowupMuteSelector = function(boardID) {
    return relatedSelector('.followup_mute', boardID);
  };

  var relatedFollowupUnmuteSelector = function(boardID) {
    return relatedSelector('.followup_unmute', boardID);
  };

  var relatedFollowupWrapperSelector = function(boardID) {
    return relatedSelector('.followup_wrapper', boardID);
  };

  var relatedFollowupPaddleSelector = function(boardID) {
    return relatedFollowupWrapperSelector(boardID) + ' .green-paddle';
  };

  var muteRelatedFollowup = function(boardID) {
    $(relatedFollowupMuteSelector(boardID)).click();
  };

  var disableRelatedFollowup = function(boardID) {
    $(relatedFollowupMuteSelector(boardID)).attr('disabled', true);
    $(relatedFollowupUnmuteSelector(boardID)).attr('disabled', true);
    $(relatedFollowupWrapperSelector(boardID)).addClass('disabled');
    $(relatedFollowupPaddleSelector(boardID)).addClass('disabled');
  };

  var enableRelatedFollowup = function(boardID) {
    $(relatedFollowupMuteSelector(boardID)).removeAttr('disabled');
    $(relatedFollowupUnmuteSelector(boardID)).removeAttr('disabled');
    $(relatedFollowupWrapperSelector(boardID)).removeClass('disabled');
    $(relatedFollowupPaddleSelector(boardID)).removeClass('disabled');
  }

  $('.digest_mute').change(function(event) {
    var boardID = $(this).data('board-id');
    muteRelatedFollowup(boardID);
    disableRelatedFollowup(boardID);
    postMuteRequest($(this));
  });

  $('.digest_unmute').change(function(event) {
    var boardID = $(this).data('board-id');
    enableRelatedFollowup(boardID);
    postMuteRequest($(this));
  });
}
