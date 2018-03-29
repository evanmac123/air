var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.DropdownButtonComponent = (function() {
  function init() {
    $(".dropdown-button-component").niceSelect();
    $(".dropdown-button-component-init").removeClass(
      "dropdown-button-component-init"
    );
  }

  function update() {
    $(".dropdown-button-component").niceSelect("update");
  }

  function reflow() {
    $(".dropdown-button-component").niceSelect("destroy");
    init();
  }

  return {
    init: init,
    update: update,
    reflow: reflow
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".dropdown-button-component")) {
    Airbo.Utils.DropdownButtonComponent.init();
  }
});
