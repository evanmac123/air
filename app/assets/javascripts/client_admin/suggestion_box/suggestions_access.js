#
var allUsers, cancelBtn, controlButtonsBlock, form, manageAccessBtn, manageAccessPrompt, modal, modalSelector, removeLinkSelector, saveBtn, searchInput, searchResultsSelector, specificUsers, switherOff, switherOn, userRow, userRows, usersTableBody, warningCancel, warningConfirm, warningModal, warningModalSelector;

allUsers = function() {
  return $(".all_users_section");
};

specificUsers = function() {
  return $(".specific_users_section");
};

switherOn = function() {
  return $('#suggestion_switcher_on');
};

switherOff = function() {
  return $('#suggestion_switcher_off');
};

modalSelector = function() {
  return '#suggestions_access_modal';
};

modal = function() {
  return $(modalSelector());
};

manageAccessBtn = function() {
  return $('#manage_access');
};

saveBtn = function() {
  return $("#save_suggestions_access");
};

cancelBtn = function() {
  return $('#cancel_suggestions_access, #suggestion_box_modal .close-reveal-modal, #close-suggestions-access-modal');
};

controlButtonsBlock = function() {
  return $('.control_buttons');
};

userRows = function() {
  return $(".allowed_to_suggest_user");
};

userRow = function(userId) {
  return $(".allowed_to_suggest_user[data-user-id=" + userId + "]");
};

usersTableBody = function() {
  return $("#allowed_to_suggest_users tbody");
};

searchInput = function() {
  return $("#name_substring");
};

searchResultsSelector = function() {
  return "#name_autocomplete_target";
};

form = function() {
  return $("#suggestions_access_form");
};

removeLinkSelector = function() {
  return ".user_remove a";
};

warningModalSelector = function() {
  return "#suggestions_access_warning_modal";
};

warningModal = function() {
  return $(warningModalSelector());
};

warningConfirm = function() {
  return $(warningModalSelector() + " .confirm");
};

warningCancel = function() {
  return $(warningModalSelector() + " .cancel, " + warningModalSelector() + " .close-reveal-modal");
};

manageAccessPrompt = function() {
  return $("#manage_access_prompt");
};

window.suggestionsAccess = function(withModalEvents) {
  var alreadyInList, blockSaveBtn, checkManageAccessPrompt, formChanged, getSelectedUser, higlightSwitcherCopy, reloadForm, showSection, specificUsersChanged, triggerModal, triggerWarningModal, turnSaveBtnSpinner, unblockSaveBtn;
  if (withModalEvents == null) {
    withModalEvents = true;
  }
  triggerModal = function(action) {
    return modal().foundation('reveal', action);
  };
  cancelBtn().click(function(e) {
    e.preventDefault();
    return triggerModal('close');
  });
  if (withModalEvents) {
    $(document).on('open.fndtn.reveal', modalSelector(), function() {
      if (!window.needToBeSaved) {
        return blockSaveBtn();
      }
    });
    $(document).on('closed.fndtn.reveal', modalSelector(), function() {
      if (window.needToBeSaved) {
        return triggerWarningModal('open');
      }
    });
    manageAccessBtn().click(function(e) {
      e.preventDefault();
      return triggerModal('open');
    });
  }
  triggerWarningModal = function(action) {
    return warningModal().foundation('reveal', action);
  };
  if (withModalEvents) {
    warningCancel().click(function(e) {
      return triggerWarningModal('close');
    });
    warningConfirm().click(function(e) {
      window.needToBeSaved = 'reload';
      return triggerWarningModal('close');
    });
    $(document).on('closed.fndtn.reveal', warningModalSelector(), function() {
      if (window.needToBeSaved === 'reload') {
        return reloadForm();
      } else {
        return triggerModal('open');
      }
    });
  }
  higlightSwitcherCopy = function(name) {
    $(".specific_users_copy, .all_users_copy").removeClass("on");
    if (name === 'allUsers') {
      return $(".all_users_copy").addClass("on");
    } else {
      return $(".specific_users_copy").addClass("on");
    }
  };
  showSection = function(name) {
    if (name === 'allUsers') {
      allUsers().slideDown();
      specificUsers().slideUp();
    } else {
      allUsers().slideUp();
      specificUsers().slideDown();
    }
    higlightSwitcherCopy(name);
    return formChanged();
  };
  switherOn().click(function(e) {
    return showSection('allUsers');
  });
  switherOff().click(function(e) {
    return showSection('specificUsers');
  });
  alreadyInList = function(userId) {
    return userRow(userId).length > 0;
  };
  getSelectedUser = function(e, ui) {
    var user;
    e.preventDefault();
    user = ui.item.value;
    if (user.found && !alreadyInList(user.id)) {
      $.ajax({
        type: 'GET',
        url: '/client_admin/allowed_to_suggest_users/' + user.id,
        success: function(data) {
          usersTableBody().prepend(data.userRow);
          return formChanged();
        }
      });
    }
    return searchInput().val('').focus();
  };
  searchInput().autocomplete({
    appendTo: searchResultsSelector(),
    source: '/client_admin/users',
    html: 'html',
    select: getSelectedUser,
    focus: function(e) {
      return e.preventDefault();
    }
  });
  checkManageAccessPrompt = function() {
    if (manageAccessPrompt().length > 0) {
      return manageAccessPrompt().remove();
    }
  };
  blockSaveBtn = function() {
    saveBtn().attr("disabled", "disabled");
    return window.needToBeSaved = false;
  };
  unblockSaveBtn = function() {
    saveBtn().removeAttr("disabled");
    return window.needToBeSaved = true;
  };
  specificUsersChanged = function() {
    if (userRows().length > 0) {
      return specificUsers().addClass("has_users");
    } else {
      return specificUsers().removeClass("has_users");
    }
  };
  formChanged = function() {
    unblockSaveBtn();
    return specificUsersChanged();
  };
  turnSaveBtnSpinner = function(action) {
    if (action == null) {
      action = 'on';
    }
    if (action === 'on') {
      blockSaveBtn();
      return controlButtonsBlock().addClass('with_spinner');
    } else {
      return controlButtonsBlock().removeClass('with_spinner');
    }
  };
  reloadForm = function() {
    return $.ajax({
      type: 'GET',
      url: '/client_admin/suggestions_access',
      success: function(data) {
        form().replaceWith(data.form);
        window.needToBeSaved = false;
        return window.suggestionsAccess(false);
      }
    });
  };

  $(document).on('click', removeLinkSelector(), function(e) {
    e.preventDefault();
    $(this).closest("tr").remove();
    return formChanged();
  });

  form().on('submit', function(e) {
    e.preventDefault();
    turnSaveBtnSpinner('on');
    return $(this).ajaxSubmit({
      dataType: 'json',
      success: function() {
        turnSaveBtnSpinner('off');
        triggerModal('close');
        return checkManageAccessPrompt();
      }
    });
  });

  $(window).on("beforeunload", function() {
    if (window.needToBeSaved) {
      return "You haven't saved your changes.";
    }
  });
  return bindIntercomOpen(".contact_airbo");
};
