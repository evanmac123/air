Airbo.TileCarouselPage = (function() {
  function initLinkFixer(){
    Airbo.Utils.TileLinkHandler.init();
  }

  function init(){
    Airbo.TileAnswers.init();
    initLinkFixer();
  }

  return {
    init: init
  };

}());
