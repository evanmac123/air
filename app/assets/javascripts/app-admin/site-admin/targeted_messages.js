var Airbo = window.Airbo || {};

Airbo.TargetedMessages = (function() {
  function init() {
    $("#send_at").datetimepicker({
      dateFormat: "DD, MM dd, yy",
      minDate: 0
    });
  }

  return {
    init: init
  };
})();

$(function() {
  if ($("#send_at").length > 0) {
    Airbo.TargetedMessages.init();
  }
});
