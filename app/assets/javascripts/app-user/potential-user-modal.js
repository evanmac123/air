var Airbo = window.Airbo || {};

Airbo.PotentialUserModal = (function() {
  function init() {
    $(".js-register-potential-user-modal").foundation("reveal", "open");

    var $submitButton = $(".js-submit-potential-user-conversion");

    $("#potential_user_name").on("input propertychange paste", function() {
      if (
        $(this)
          .val()
          .match(/\w+\s+\w+/)
      ) {
        $submitButton.removeAttr("disabled");
      } else {
        $submitButton.attr("disabled", "disabled");
      }
    });
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".js-register-potential-user-modal").length > 0) {
    Airbo.PotentialUserModal.init();
  }
});
