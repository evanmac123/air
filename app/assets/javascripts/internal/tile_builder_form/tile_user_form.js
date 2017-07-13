var Airbo = window.Airbo || {};

Airbo.TileUserForm = (function(){
  function updateSections(data) {
    Airbo.Utils.alertSuccess("Thanks for suggesting a Tile!", "You will be notified when the Tile is posted.");
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
  };

}());

$(function(){
  if( $("#submit_tile").length > 0 ) {
    Airbo.TileUserForm.init();

    if( $("#submit_tile").data("display") === true) {
      $("#submit_tile").trigger("click");
    }
  }
});
