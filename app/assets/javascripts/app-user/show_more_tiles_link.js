var bindShowMoreTilesLink;
var currentPage = 1;
bindShowMoreTilesLink = function(
  moreTilesSelector,
  tileSelector,
  spinnerSelector,
  downArrowSelector,
  targetSelector,
  updateMethod,
  afterRenderCallback,
  tileType
) {
  $("body").on("click", moreTilesSelector, function(event) {
    var offset;
    var self = $(this);
    var path = self.data("tile-path") || self.attr("href");
    var contentType = self.data("contentType");
    event.preventDefault();
    currentPage = currentPage + 1;
    if (self.attr("disabled") == "disabled") {
      return;
    }

    $(downArrowSelector).hide();
    $(spinnerSelector).show();

    offset = $(tileSelector).length;

    $.get(
      path,
      {
        offset: offset,
        partial_only: "true",
        page: currentPage,
        tile_type: tileType
      },
      function(data) {
        var content = data.htmlContent || data;
        $(spinnerSelector).hide();
        $(downArrowSelector).show();
        switch (updateMethod) {
          case "append":
            $(targetSelector).append(content);
            break;
          case "replace":
            $(targetSelector).replaceWith(content);
        }

        if (data.lastBatch) {
          $(moreTilesSelector).attr("disabled", "disabled");
        }

        if (typeof afterRenderCallback === "function") {
          afterRenderCallback();
        }
      },
      contentType
    );
  });
};
