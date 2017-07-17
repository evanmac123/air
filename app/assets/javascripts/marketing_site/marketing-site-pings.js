var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Pings = (function() {
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

  function standaloneFormPings(email) {
    Airbo.Utils.ping("New Lead", { email: email });
  }

  function init() {
    bindCtas();
    bindCaseStudyViewButtons();
  }

  return {
    init: init,
    standaloneFormPings: standaloneFormPings
  };
}());

$(function(){
  if (Airbo.Utils.nodePresent(".airbo-marketing-site")) {
    Airbo.MarketingSite.Pings.init();
  }
});
