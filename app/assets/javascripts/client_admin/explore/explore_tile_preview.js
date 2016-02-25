var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var copyBtnSel = ".copy_to_board"
    , copyBtn
  ;
  function initEvents() {
    copyBtn.click(function(event) {
      event.preventDefault();
      copyUrl = $(this).attr("href");
      $.post(copyUrl, {},
        function(data) {
          if(data.success) {
            Airbo.CopyAlert.open();
          }
        },
        'json'
      );
    });
  }
  function initVars() {
    copyBtn = $(copyBtnSel);
    Airbo.ShareLink.init();
  }
  function init() {
    initVars();
    initEvents();
  }
  return {
    init: init
  }
}());

$(document).ready(function(){
  if( $(".explore_menu").length > 0 ) {
    Airbo.ExploreTilePreview.init();
  }
});