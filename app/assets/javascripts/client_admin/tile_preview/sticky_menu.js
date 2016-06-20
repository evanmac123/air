Airbo = window.Airbo || {};

Airbo.StickyMenu = (function(){
  function init(containter){
    var modal = $("#" + containter.modalId);
    var previewMenu = modal.find('.tile_preview_menu');
    modal.scroll(function() {
      if (modal.scrollTop() > 50) {
        sizes = containter.tileContainerSizes();
        previewMenu.addClass('sticky').css("left", sizes.left);
      } else {
        previewMenu.removeClass('sticky').css("left", "");
      }
    });
  }
  return {
    init: init
  }
}());
