var Airbo = window.Airbo || {}


Airbo.DigestEmailFollowUpManager = (function(){
  var commandSelector = ".commands .button"
    , editSelector = ".commands .edit"
    , saveSelector = ".commands .save"
    , nowSelector = ".commands .now"
    , deleteSelector = ".commands .delete"
  ;

  function initToggleEditForm(){
    $(editSelector).on("click", function(event){
      event.preventDefault();
      var row = $(this).parents("tr");
      row.find("input").prop("disabled", false) 
    });
  }

  function initSendNow(){
    $(editSelector).on("click", function(event){
      event.preventDefault();
      var row = $(this).parents("tr");
      row.find("input").prop("disabled", false) 
    });
  }

  function initCommandHander(){
    $(commandSelector).on("click", function(event){
      event.preventDefault();
      var command = $(this)
        , row = $(this).parents("tr")   
      ;

      switch(command){
      case  
      case
      case
      }
      row.find("input").prop("disabled", false) 
    });
  }

  function initSave(){

  }

  function init(){
    initToggleEditForm();
  }

  return {
    init: init,
  }

}());

$(function(){
  Airbo.DigestEmailFollowUpManager.init();
})
