var Airbo = window.Airbo || {};

Airbo.BoardModalManager = (function() {
  function init() {
    Airbo.BoardWelcomeModal.init();
    Airbo.BoardPrizeModal.init();

    launchOnLoadModal();
  }

  function launchOnLoadModal() {
    if (Airbo.BoardWelcomeModal.showOnLoad()) {
      Airbo.BoardWelcomeModal.open();
    } else if (Airbo.BoardPrizeModal.showOnLoad()) {
      Airbo.BoardPrizeModal.open();
    }
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent("#user_progress")) {
    Airbo.BoardModalManager.init();
  }
});
