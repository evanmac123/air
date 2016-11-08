var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.ButtonSpinner = (function(){
  function trigger(button) {
    button.addClass("disabled");
    button.children("#button_text").hide();
    button.children("#button_spinner").toggle();
    button.children("#button_complete").hide();
    button.removeClass("green");
  }

  function completeSuccess(button, removeDisabled) {
    button.children("#button_spinner").toggle();
    button.addClass("green");
    button.children("#button_complete").toggle();

    if (removeDisabled) {
      button.removeClass("disabled");
    }
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
