var Airbo = window.Airbo || {};

Airbo.MarketingPagePings = (function(){
  function preSignupPings() {
    $(".pre-signup").submit(function() {
      var email = $(this).children("#email").val();
      Airbo.Utils.ping("Marketing Page: Pre Signup", { source: "Marketing Page v. 8/1/2016", email: email });
    });
  }

  function footerPings() {
    $(".company-link").on("click", function() {
      Airbo.Utils.ping("Marketing Page: Link Clicked", { link: "Company", source: "Marketing Page v. 8/1/2016" });
    });
    $(".careers-link").on("click", function() {
      Airbo.Utils.ping("Marketing Page: Link Clicked", { link: "Careers", source: "Marketing Page v. 8/1/2016" });
    });
    $(".case-studies-link").on("click", function() {
      Airbo.Utils.ping("Marketing Page: Link Clicked", { link: "Case Studies", source: "Marketing Page v. 8/1/2016" });
    });
    $(".blog-link").on("click", function() {
      Airbo.Utils.ping("Marketing Page: Link Clicked", { link: "Blog", source: "Marketing Page v. 8/1/2016" });
    });
    $(".schedule-demo-link").on("click", function() {
      Airbo.Utils.ping("Marketing Page: Link Clicked", { link: "Schedule a Demo", source: "Marketing Page v. 8/1/2016" });
    });
  }

  function signupRequestPings(email) {
    Airbo.Utils.ping("Marketing Page: Signup Request Submitted", { source: "Marketing Page v. 8/1/2016", email: email });
    Airbo.Utils.ping("New Lead", { "action": "Signup Request", email: email } );
  }

  function demoRequestPings(email) {
    Airbo.Utils.ping("Marketing Page: Demo Request Submitted", { source: "Marketing Page v. 8/1/2016", email: email });
    Airbo.Utils.ping("New Lead", { "action": "Demo Request", email: email });
  }


  function init() {
    preSignupPings();
    footerPings();
  }

  return {
    init: init,
    signupRequestPings: signupRequestPings,
    demoRequestPings: demoRequestPings
  };
}());
