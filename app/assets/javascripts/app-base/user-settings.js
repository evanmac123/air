var Airbo = window.Airbo || {};

Airbo.UserSettings = (function() {
  function init() {
    $(".js-receives-sms-checkbox").show();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-user-settings")) {
    Airbo.UserSettings.init();
  }
});
