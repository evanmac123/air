//Disclaimer: This code was from a contractor (with slight restructuring). #gitblamelies.

var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Home = (function(){
  function initHeaderMobileMenu() {
    $('.btn-menu').click(function() {
      $('.marketing-site-header').toggleClass('mobile-nav');
    });
  }

  function bindCtas() {
    $(".js-marketing-site-cta").on("click", function(e) {
      e.preventDefault();

      Airbo.Utils.ping("Marketing Site Action", { action: "CTA Clicked", cta: $(this).data("cta"), copy: $(this).text(), color: $(this).css("background-color") });

      window.location = $(this).data("path");
    });
  }

  function init() {
    initHeaderMobileMenu();
    bindCtas();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".pages-home")) {
    Airbo.MarketingSite.Home.init();
  }
});
