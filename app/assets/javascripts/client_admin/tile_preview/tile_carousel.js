Airbo.TileCarouselPage = (function() {
  function initLinkFixer(){
    Airbo.Utils.ExternalLinkHandler.init();
  }

  function init(){
    Airbo.TileAnswers.init();
    initLinkFixer();
  }
  return {
    init: init
  }

}());
