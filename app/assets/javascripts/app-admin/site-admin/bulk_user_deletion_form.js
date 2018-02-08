var Airbo = window.Airbo || {};

Airbo.BulkUserDeleter = (function() {
  var form;

  function initFormSubmit() {
    form.submit(function(event) {
      var confirmation;
      if (form.find("input[type=checkbox]:checked").length === 0) {
        alert("You must select at least one group of users to to delete");
        return false;
      } else {
        if (confirm("Are you sure? This action cannot be undone")) {
          return true;
        } else {
          return false;
        }
      }
    });
  }

  function init() {
    form = $("#admin_bulk_user_delete");
    initFormSubmit();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($("#admin_bulk_user_delete").length > 0) {
    Airbo.BulkUserDeleter.init();
  }
});
