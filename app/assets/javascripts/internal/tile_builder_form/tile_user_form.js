var Airbo = window.Airbo || {};

Airbo.TileUserForm = (function(){
  function updateSections(data) {
    // do nothing
  }
  function initEvents() {
    $("#submit_tile").click(function(e) {
      e.preventDefault();

      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileUserForm);
      tileForm.open(url);
    });
  }
  function init() {
    initEvents();
  }
  return {
    init: init,
    updateSections: updateSections
  }
}());

$(function(){
  if( $("#submit_tile").length > 0 ) {
    Airbo.TileUserForm.init();
  }
});
