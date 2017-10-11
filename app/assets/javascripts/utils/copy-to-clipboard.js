var Airbo = window.Airbo || {};

Airbo.CopyToClipboard = (function(){

  function init() {
    clipboard = new Clipboard(".js-copy-to-clipboard-btn");
    clipboard.on('success', function(e) {
      e.clearSelection();
      Airbo.Utils.ping("Copied to clipboard", { data: e.text });
      
      Foundation.libs.tooltips.getTip($(e.trigger)).html('Copied!<span class="nub"></span>');
      window.setTimeout(function() {
        Foundation.libs.tooltips.getTip($(e.trigger)).html('Click to Copy<span class="nub"></span>');
      }, 3000);
    });
  }

  return {
    init: init
  };

}());

$(function(){
  Airbo.CopyToClipboard.init();
});
