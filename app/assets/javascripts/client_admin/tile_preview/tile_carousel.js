Airbo.TileCarouselPage = (function() {
  function initLinkFixer(){
    Airbo.Utils.ExternalLinkHandler.init();
  }

  function init(){
    // grayoutTile();
    Airbo.TileAnswers.init();
    // ungrayoutTile();
    initLinkFixer();
  }
  return {
    init: init
  }

}());
