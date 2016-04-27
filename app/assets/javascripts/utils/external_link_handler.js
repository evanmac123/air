var Airbo = window.Airbo ||{};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.ExternalLinkHandler= (function(){
  var tilePresenceSelector =  ".tile_holder";



  function init(){
      $('body .tile_texts_container a').each(function() {
        var a = new RegExp('/' + window.location.host + '/');
        if(!a.test(this.href)) {
          $(this).click(function(event) {
            event.preventDefault();
            event.stopPropagation();
            window.open(this.href, '_blank');
          });
        }
      });
     }

  return {
   init: init,
  }
}());


