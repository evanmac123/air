var Airbo = window.Airbo || {};

Airbo.UserRemover = (function() {
  var form;

  function initFormSubmit() {
    form.submit(function(event) {
      var confirmation;
      if (form.find("input[type=checkbox]:checked").length === 0) {
        alert("You must select at least one user to remove from this board");
        return false;
      } else {
        if (confirm("Are you sure?")) {
          return true;
        } else {
          return false;
        }
      }
    });
  }

  function init() {
    form = $("#board_user_removal_form");
    initFormSubmit();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($("#board_user_removal_form").length > 0) {
    Airbo.UserRemover.init();
  }
});
