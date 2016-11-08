var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.ButtonSpinner = (function(){
  function trigger(button) {
    button.addClass("disabled");
    button.children("#button_text").toggle();
    button.children("#button_spinner").toggle();
  }

  function completeSuccess(button) {
    button.children("#button_spinner").toggle();
    button.addClass(green);
    button.children("#button_complete").toggle();
  }

  function completeError(button) {
    button.removeClass("disabled");
    button.children("#button_text").toggle();
    button.children("#button_spinner").toggle();
  }

  return {
    trigger: trigger,
    completeSuccess: completeSuccess,
    completeError: completeError
  };

}());
