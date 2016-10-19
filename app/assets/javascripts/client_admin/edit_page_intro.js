var Airbo = window.Airbo || {}
Airbo.ClientAdminEditIntro = (function(){

  function setupClientAdminEditIntro(){
    var intro, options = {
      steps: [
        {
          intro: "This is where manage your Tiles. Let's go over the basic sections.",
        },
        {
          element: "#draft_tiles",
          intro: "Draft is where you'll find Tiles you've copied or created but have posted."
        },

        {
          element: "#active_tiles",
          intro: "Posted Tiles are Tiles that have been shared or ready to shared with your employees.",
          position: "top"
        },

        {
          element: "#archived_tiles",
          intro: "Archived Tiles are Tiles that you no longer want to share with employees."
        },

        {
          intro: "Click here to create a new Tile from scratch.",
          element: "#add_new_tile"
        },
      ],
    };


    intro = Airbo.Utils.IntroJs.init(options);
    intro.start();
    intro.oncomplete(function() {
      triggerModal("#onboarding-complete-modal", 'open');
      Airbo.UserOnboardingUpdate.thirdUpdate($(".onboarding-body").data("id"));
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
  if(Airbo.Utils.supportsFeatureByPresenceOfSelector(".manage_tiles")){
    Airbo.ClientAdminEditIntro.init();
  }
})
