Airbo.TopicBoards = (function(){
  function init(){
    if(Airbo.Utils.supportsFeatureByPresenceOfSelector(".topic-board-form")){
      Airbo.Utils.initChosen();
    }
  }

  return {
   init: init,
  }

}());


$(function(){
  Airbo.TopicBoards.init();
})


