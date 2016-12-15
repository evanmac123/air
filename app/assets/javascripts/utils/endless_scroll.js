var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.EndlessScroll = (function(){
  function init(content_container) {
    var approachingBottomOfPage,
        isLoadingNextPage,
        lastLoadAt,
        spaceAboveBottom,
        minTimeBetweenPages,
        nextPage,
        viewMore,
        waitedLongEnoughBetweenPages,
        lastBatch;

    viewMore = content_container.siblings($('.endless_scroll_loading'));
    isLoadingNextPage = false;
    lastLoadAt = null;
    minTimeBetweenPages = 500;
    spaceAboveBottom = 1500;

    waitedLongEnoughBetweenPages = function() {
      return lastLoadAt === null || new Date() - lastLoadAt > minTimeBetweenPages;
    };

    approachingBottomOfPage = function() {
      return $(window).scrollTop() + $(window).height() > $(document).height() - spaceAboveBottom;
    };

    nextPage = function() {
      var path = content_container.data("path");

      if (isLoadingNextPage || !path) {
        return;
      }

      isLoadingNextPage = true;
      lastLoadAt = new Date();

      var page = parseInt(content_container.data("page")) || 0;
      page += 1;
      var count = content_container.data("count");

      $.ajax({
        url: path,
        data: { page: page, count: count },
        method: 'GET',
        dataType: 'json',
        success: function(data) {
          content_container.data("page", page);
          content_container.data("count", count + data.added);
          content_container.append(data.content);
          lastBatch = data.lastBatch;
          isLoadingNextPage = false;
          lastLoadAt = new Date();

          if (lastBatch === true) {
            viewMore.hide();
          }
        }
      });
    };

    $(window).scroll(function() {
      if (content_container.is(':visible') && approachingBottomOfPage() && waitedLongEnoughBetweenPages()) {
        if (lastBatch === false || lastBatch === undefined) {
          return nextPage();
        }
      }
    });
  }

  return {
    init: init
  };

}());

$(function(){
  if( $('.endless_scroll_content_container').length > 0 ) {
    $('.endless_scroll_content_container').each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container));
    });
  }
});
