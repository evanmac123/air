var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.EndlessScroll = (function(){
  function init(content_container) {
    var approachingBottomOfPage,
        isLoadingNextPage,
        minCount,
        lastLoadAt,
        spaceAboveBottom,
        minTimeBetweenPages,
        nextPage,
        viewMore,
        waitedLongEnoughBetweenPages,
        lastBatch;

    isLoadingNextPage = false;
    lastLoadAt = null;

    viewMore = content_container.siblings($('.endless_scroll_loading'));
    minTimeBetweenPages = content_container.data("minTimeBetweenPages") || 500;
    spaceAboveBottom = content_container.data("spaceAboveBottom") || 1500;
    minCount = content_container.data("minCount") || 28;

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

      var count = content_container.data("count");
      if (count >= minCount) {
        viewMore.show();
        isLoadingNextPage = true;
        lastLoadAt = new Date();

        var page = parseInt(content_container.data("page")) || 0;
        page += 1;

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
      }
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