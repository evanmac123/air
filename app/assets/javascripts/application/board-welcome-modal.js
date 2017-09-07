var Airbo = window.Airbo || {};

Airbo.BoardWelcomeModal = (function(){
  var self;
  function init() {
    self = $(".js-board-welcome-modal");

    if (self.data("showOnLoad") === true) {
      self.foundation("reveal", "open");
    }
  }

  return {
    init: init
  };

}());

$(function() {
  if (Airbo.Utils.nodePresent(".js-board-welcome-modal")) {
    Airbo.BoardWelcomeModal.init();
  }
});
