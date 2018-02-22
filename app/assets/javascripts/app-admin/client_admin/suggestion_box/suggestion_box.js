var Airbo = window.Airbo || {};

Airbo.SuggestionBox = (function() {
  function init() {
    Airbo.SuggestionBoxAccessManager.init();
  }

  return {
    init: init
  };
})();
