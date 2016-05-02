var bindShowMoreTilesLink;

bindShowMoreTilesLink = function(moreTilesSelector, tileSelector, spinnerSelector, targetSelector, updateMethod, afterRenderCallback) {
  return $(moreTilesSelector).live('click', function(event) {
    var offset;
    event.preventDefault();
    if ($(this).attr('disabled') !== 'disabled') {
      $(spinnerSelector).show();
      offset = $(tileSelector).length;
      return $.get($(this).data('tile-path'), {
        offset: offset,
        partial_only: 'true'
      }, (function(data) {
        $(spinnerSelector).hide();
        switch (updateMethod) {
          case 'append':
            $(targetSelector).append(data.htmlContent);
          break;
          case 'replace':
            $(targetSelector).replaceWith(data.htmlContent);
        }
        if (data.lastBatch) {
          $(moreTilesSelector).attr('disabled', 'disabled');
        }
        if (typeof afterRenderCallback === 'function') {
          return afterRenderCallback();
        }
      }));
    }
  });
