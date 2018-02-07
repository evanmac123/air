var Airbo = window.Airbo || {};
Airbo.SuggestionBoxAccessManager = (function() {
  var modalSelector = "#suggestions_access_modal",
    searchResultsSelector = "#name_autocomplete_target",
    allUsers,
    specificUsers,
    switherOn,
    switherOff,
    modal,
    manageAccessBtn,
    saveBtn,
    cancelBtn,
    controlButtonsBlock,
    userRows,
    userRow,
    usersTableBody,
    searchInput,
    form,
    removeLinkSelector,
    warningModalSelector,
    warningModal,
    warningConfirm,
    warningCancel,
    manageAccessPrompt;

  function triggerModal(action) {
    modal.foundation("reveal", action);
  }

  function triggerWarningModal(action) {
    warningModal.foundation("reveal", action);
  }

  function higlightSwitcherCopy(name) {
    $(".specific_users_copy, .all_users_copy").removeClass("on");
    if (name === "allUsers") {
      $(".all_users_copy").addClass("on");
    } else {
      $(".specific_users_copy").addClass("on");
    }
  }

  function showSection(name) {
    if (name === "allUsers") {
      allUsers.slideDown();
      specificUsers.slideUp();
    } else {
      allUsers.slideUp();
      specificUsers.slideDown();
    }
    higlightSwitcherCopy(name);
    formChanged();
  }

  function userRow(userId) {
    return $(".allowed_to_suggest_user[data-user-id=" + userId + "]");
  }

  function getSelectedUser(e, ui) {
    var user;
    e.preventDefault();
    user = ui.item.value;
    if (user.found && !alreadyInList(user.id)) {
      $.ajax({
        type: "GET",
        url: "/client_admin/allowed_to_suggest_users/" + user.id,
        success: function(data) {
          usersTableBody.prepend(data.userRow);
          formChanged();
        }
      });
    }
    searchInput.val("").focus();
  }

  function checkManageAccessPrompt() {
    if (manageAccessPrompt.length > 0) {
      return manageAccessPrompt.remove();
    }
  }

  function blockSaveBtn() {
    saveBtn.attr("disabled", "disabled");
    return (window.needToBeSaved = false);
  }

  function unblockSaveBtn() {
    saveBtn.removeAttr("disabled");
    return (window.needToBeSaved = true);
  }

  function specificUsersChanged() {
    if (userRows.length > 0) {
      return specificUsers.addClass("has_users");
    } else {
      return specificUsers.removeClass("has_users");
    }
  }

  function formChanged() {
    unblockSaveBtn();
    return specificUsersChanged();
  }

  function turnSaveBtnSpinner(action) {
    if (action == null) {
      action = "on";
    }
    if (action === "on") {
      blockSaveBtn();
      return controlButtonsBlock.addClass("with_spinner");
    } else {
      return controlButtonsBlock.removeClass("with_spinner");
    }
  }

  function alreadyInList(userId) {
    return userRow(userId).length > 0;
  }

  function reloadForm() {
    return $.ajax({
      type: "GET",
      url: "/client_admin/suggestions_access",
      success: function(data) {
        form.replaceWith(data.form);
        window.needToBeSaved = false;
      }
    });
  }

  function initDom() {
    allUsers = $(".all_users_section");
    specificUsers = $(".specific_users_section");
    switherOn = $("#suggestion_switcher_on");
    switherOff = $("#suggestion_switcher_off");
    modal = $(modalSelector);
    manageAccessBtn = $("#manage_access");
    saveBtn = $("#save_suggestions_access");
    cancelBtn = $(
      "#cancel_suggestions_access, #suggestion_box_modal .close-reveal-modal, #close-suggestions-access-modal"
    );
    controlButtonsBlock = $(".control_buttons");
    userRows = $(".allowed_to_suggest_user");
    usersTableBody = $("#allowed_to_suggest_users tbody");
    searchInput = $("#name_substring");
    form = $("#suggestions_access_form");
    removeLinkSelector = ".user_remove a";
    warningModalSelector = "#suggestions_access_warning_modal";
    warningModal = $(warningModalSelector);
    warningConfirm = $(warningModalSelector + " .confirm");
    warningCancel = $(
      warningModalSelector +
        " .cancel, " +
        warningModalSelector +
        " .close-reveal-modal"
    );
    manageAccessPrompt = $("#manage_access_prompt");
  }

  function initEvents() {
    manageAccessBtn.click(function(e) {
      e.preventDefault();
      return triggerModal("open");
    });

    cancelBtn.click(function(e) {
      e.preventDefault();
      return triggerModal("close");
    });

    switherOn.click(function(e) {
      return showSection("allUsers");
    });

    switherOff.click(function(e) {
      return showSection("specificUsers");
    });

    searchInput.autocomplete({
      appendTo: searchResultsSelector,
      source: "/client_admin/users",
      html: "html",
      select: getSelectedUser,
      focus: function(e) {
        e.preventDefault();
      }
    });

    $("body").on("click", removeLinkSelector, function(e) {
      e.preventDefault();
      $(this)
        .closest("tr")
        .remove();
      return formChanged();
    });

    form.on("submit", function(e) {
      e.preventDefault();
      turnSaveBtnSpinner("on");
      return $(this).ajaxSubmit({
        dataType: "json",
        success: function() {
          turnSaveBtnSpinner("off");
          triggerModal("close");
          return checkManageAccessPrompt();
        }
      });
    });
  }

  function init() {
    initDom();
    initEvents();
    setupConfirmationModal();
  }

  // TODO this functionality should be replaced with sweetalert and
  // better method of dirty detection on the form

  function setupConfirmationModal(withModalEvents) {
    if (withModalEvents == null) {
      withModalEvents = true;

      $("body").on("open.fndtn.reveal", modalSelector, function() {
        if (!window.needToBeSaved) {
          return blockSaveBtn();
        }
      });

      $("body").on("closed.fndtn.reveal", modalSelector, function() {
        if (window.needToBeSaved) {
          return triggerWarningModal("open");
        }
      });

      $("body").on("closed.fndtn.reveal", warningModalSelector, function() {
        if (window.needToBeSaved === "reload") {
          return reloadForm();
        } else {
          return triggerModal("open");
        }
      });

      warningCancel.click(function(e) {
        return triggerWarningModal("close");
      });

      warningConfirm.click(function(e) {
        window.needToBeSaved = "reload";
        return triggerWarningModal("close");
      });
    }
  }

  return {
    init: init
  };
})();

// NOTE  not sure if this is still needed
$(window).on("beforeunload", function() {
  if (window.needToBeSaved) {
    return "You haven't saved your changes.";
  }
});
