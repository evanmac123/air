var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.EndlessScrollUtil = (function() {
  function init($contentContainer, loadCallback) {
    var MIN_TIME_BETWEEN_LOADS = 1000;
    var SPACE_ABOVE_BOTTOM = 200;
    var lastLoadAt = null;

    function waitedLongEnoughBetweenPages() {
      return (
        lastLoadAt === null || new Date() - lastLoadAt > MIN_TIME_BETWEEN_LOADS
      );
    }

    function approachingBottomOfPage() {
      return (
        $(window).scrollTop() + $(window).height() >
        $(document).height() - SPACE_ABOVE_BOTTOM
      );
    }

    function loadMore() {
      lastLoadAt = new Date();
      loadCallback($contentContainer);
    }

    function shouldLoadMore() {
      return (
        $contentContainer.is(":visible") &&
        $contentContainer.data("lastPage") === false &&
        $(".js-endless-scroll-loading:visible").length === 0 &&
        approachingBottomOfPage() &&
        waitedLongEnoughBetweenPages()
      );
    }

    $(window).scroll(function() {
      if (shouldLoadMore()) {
        return loadMore();
      }
    });
  }

  return {
    init: init
  };
})();
