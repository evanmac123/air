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

  function bindCaseStudyViewButtons() {
    $(".js-case-study-view-button").on("click", function(e) {
      e.preventDefault();

      Airbo.Utils.ping("Marketing Site Action", { action: "Viewed Case Study", case_study: $(this).data("caseStudy"), copy: $(this).text(), color: $(this).css("background-color") });

      window.open($(this).attr("href"));
    });
  }

  function init() {
    initHeaderMobileMenu();
    bindCtas();
    bindCaseStudyViewButtons();
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".airbo-marketing-site")) {
    Airbo.MarketingSite.Home.init();
  }
});
