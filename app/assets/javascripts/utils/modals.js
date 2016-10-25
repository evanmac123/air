var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.Modals = (function(){
  function trigger(modalSelector, action) {
    $(modalSelector).foundation('reveal', action, {
      animation: 'fadeAndPop',
      animation_speed: 350
    });
  }

  function close(modal) {
    Airbo.Utils.Modals.trigger(modal, "close");
  }

  function bindClose() {
    $(".close-airbo-modal").on("click", function() {
      var modal = this.closest(".reveal-modal");
      Airbo.Utils.Modals.trigger(modal, "close");
    });
  }

  return {
    trigger: trigger,
    close: close,
    bindClose: bindClose
  };

}());
