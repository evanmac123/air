var Airbo = window.Airbo || {};

Airbo.TileUserForm = (function(){
  function updateSections(data) {
    // do nothing
  }
  function initEvents() {
    $("#submit_tile").click(function(e) {
      e.preventDefault();
     
      if(Airbo.Utils.isOldIE()){
        alert("You must upgrade to the newest version of Internet Explorer or use a different broswer suchs as Google Chrome, Apple Safari, or Mozilla Firefox to use this feature");
        return;
      }

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
