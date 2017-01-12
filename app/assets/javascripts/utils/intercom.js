var Airbo = window.Airbo || {};

Airbo.OpenIntercom = (function(){
  function init() {
    $('.open_intercom').on('click', function(event) {
      event.preventDefault();
      openIntercom();
    });
  }

  function openIntercom() {
    Intercom('show');
  }

  return {
    init: init
  };

}());

$(function(){
  if ($(".open_intercom").length > 0) {
    Airbo.OpenIntercom.init();
  }
});
