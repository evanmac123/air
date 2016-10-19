var Airbo = window.Airbo || {};
Airbo.ClientAdminEditIntro = (function(){

  function setupClientAdminEditIntro(){
    var intro, options = {
      tooltipClass: "airbo-onboarding",
      doneLabel: "Get Started",
      steps: [
        {
          intro: "This is where manage your Tiles. Let's go over the basic sections.",
        },
        {
          element: "#draft_tiles",
          intro: "Draft is where you'll find Tiles you've copied or created but have not posted."
        },

        {
          element: "#active_tiles",
          intro: "Posted Tiles are Tiles that have been shared or are ready to be shared with your employees.",
          position: "top"
        },
      ],
    };


    intro = Airbo.Utils.IntroJs.init(options);
    intro.start();
    intro.oncomplete(function() {
      Airbo.Utils.Modals.trigger("#from-onboarding-modal", 'open');
    });
  }

  function init(){
    setupClientAdminEditIntro();
  }

  return {
    init: init,
  };


}());

$(function(){
  if(Airbo.Utils.supportsFeatureByPresenceOfSelector("#from-onboarding-modal")){
    Airbo.ClientAdminEditIntro.init();
  }
});
