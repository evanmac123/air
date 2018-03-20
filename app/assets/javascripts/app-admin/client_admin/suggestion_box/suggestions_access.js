var Airbo = window.Airbo || {};
Airbo.SuggestionBoxAccessManager = (function() {
  var modalSelector = ".js-suggestions-access-modal";
  var warningModalSelector = "#suggestions_access_warning_modal";

  function triggerModal(action) {
    $(modalSelector).foundation("reveal", action);
  }

  function triggerWarningModal(action) {
    $(warningModalSelector).foundation("reveal", action);
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
      $(".all_users_section").slideDown();
      $(".specific_users_section").slideUp();
    } else {
      $(".all_users_section").slideUp();
      $(".specific_users_section").slideDown();
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
          $("#allowed_to_suggest_users tbody").prepend(data.userRow);
          formChanged();
        }
      });
    }
    $("#name_substring")
      .val("")
      .focus();
  }

  function checkManageAccessPrompt() {
    if ($("#manage_access_prompt").length > 0) {
      return $("#manage_access_prompt").remove();
    }
  }

  function blockSaveBtn() {
    $(".js-save-suggestions-access").attr("disabled", "disabled");
  }

  function unblockSaveBtn() {
    $(".js-save-suggestions-access").removeAttr("disabled");
  }

  function specificUsersChanged() {
    if ($(".allowed_to_suggest_user").length > 0) {
      return $(".specific_users_section").addClass("has_users");
    } else {
      return $(".specific_users_section").removeClass("has_users");
    }
  }

  function formChanged() {
    unblockSaveBtn();
    return specificUsersChanged();
  }

  function alreadyInList(userId) {
    return userRow(userId).length > 0;
  }

  function reloadForm() {
    return $.ajax({
      type: "GET",
      url: "/client_admin/suggestions_access",
      success: function(data) {
        $("#suggestions_access_form").replaceWith(data.form);
        window.needToBeSaved = false;
      }
    });
  }

  function initEvents() {
    $(".js-suggestion-box-manage-access").click(function(e) {
      e.preventDefault();
      return triggerModal("open");
    });

    $(".js-cancel-suggestions-access").click(function(e) {
      e.preventDefault();
      return triggerModal("close");
    });

    $("#suggestion_switcher_on").click(function(e) {
      return showSection("allUsers");
    });

    $("#suggestion_switcher_off").click(function(e) {
      return showSection("specificUsers");
    });

    $("#name_substring").autocomplete({
      appendTo: "#name_autocomplete_target",
      source: "/client_admin/users",
      html: "html",
      select: getSelectedUser,
      focus: function(e) {
        e.preventDefault();
      }
    });

    $("body").on("click", ".user_remove a", function(e) {
      e.preventDefault();
      $(this)
        .closest("tr")
        .remove();
      return formChanged();
    });

    $(".js-save-suggestions-access").on("click", function(e) {
      e.preventDefault();
      var $button = $(this);
      var $form = $(this).closest("form");

      $button.addClass("with_spinner");
      return $form.ajaxSubmit({
        dataType: "json",
        success: function() {
          $button.removeClass("with_spinner");
          triggerModal("close");
          return checkManageAccessPrompt();
        }
      });
    });
  }

  function init() {
    initEvents();
  }

  return {
    init: init
  };
})();
