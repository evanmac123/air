var Airbo = window.Airbo || {};
Airbo.TileInteractionMenuHandler =(function(){
  var subtypeSelectedCallback
    , dropdownSelector = ".f-dropdown"
    , typeSelector = ".type"
    , subtypeSelector = ".subtype"
  ;

  function initQuestionTypeMenus(){
    $("body").on("click", typeSelector, function(event){
      closeMenuDropDowns();
      $(this).addClass("open");
    });
  }

  function closeMenuDropDowns(){
    $(dropdownSelector).each(function() {
      $(this).removeClass("open").removeAttr("style");
    });
  }


  function setSelected(type, subtype) {

    $(".button.selected").removeClass("selected");
    $(".subtype.selected").removeClass("selected");

    $("#" + type).addClass("selected");
    $(".subtype." + type + "." + subtype).addClass("selected");
  }


  function initSubType(callback) {
    $("body").on("click", subtypeSelector, function(event){
      var target = $(this)
        , config = target.data().config
      ;
    closeMenuDropDowns();
      if(!(target.hasClass("selected"))){
        callback(config);
        setSelected(config.type, config.subtype);
      }
    });
  }



  function init(callback){
    initSubType(callback);
    initQuestionTypeMenus();
  }

  return {

    init: init,
    setSelected: setSelected
  };

}());

