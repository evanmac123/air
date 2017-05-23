var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.EndlessScrollUtil = (function(){
  function init(content_container, loadCallback) {
    var MIN_TIME_BETWEEN_LOADS = 500;
    var SPACE_ABOVE_BOTTOM = 200;

    var isLoadingNextPage = false;
    var lastLoadAt = null;

    function waitedLongEnoughBetweenPages() {
      return lastLoadAt === null || new Date() - lastLoadAt > MIN_TIME_BETWEEN_LOADS;
    }

    function approachingBottomOfPage() {
      return $(window).scrollTop() + $(window).height() > $(document).height() - SPACE_ABOVE_BOTTOM;
    }

    function loadMore() {
      if (isLoadingNextPage) {
        return;
      }

      var lastLoadAt = new Date();
      var isLoadingNextPage = true;

      loadCallback();
    }

    $(window).scroll(function() {
      if (content_container.is(':visible') && approachingBottomOfPage() && waitedLongEnoughBetweenPages()) {
        if (lastBatch === false || lastBatch === undefined) {
          return loadMore();
        }
      }
    });
  }

  return {
    init: init
  };

}());
