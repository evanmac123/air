Airbo = window.Airbo || {};

Airbo.StickyMenu = (function(){
  function init(container){
    var modal = $("#" + container.modalId);
    var previewMenu = modal.find('.tile_preview_menu');
    modal.scroll(function() {
      if (modal.scrollTop() > 55) {
        var leftOffset = getSizes(container);
        previewMenu.addClass('sticky').css("left", leftOffset);
      } else {
        previewMenu.removeClass('sticky').css("left", "");
      }
    });
  }

  function getSizes(container) {
    if (Airbo.TileModalUtils.tileContainerSizes().left > 0) {
      return Airbo.TileModalUtils.tileContainerSizes().left;
    } else {
      var holderSize = $('.tile_holder').last().outerWidth();
      var modalSize = $('#tile_preview_modal').outerWidth();
      return (modalSize - holderSize) / 2;
    }
  }

  return {
    init: init
  };
}());
