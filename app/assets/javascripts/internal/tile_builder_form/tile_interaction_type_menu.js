var Airbo = window.Airbo || {};
Airbo.TileInteractionMenuHandler =(function(){
  var subtypeSelectedCallback
    , dropdownSelector = ".f-dropdown"
    , typeSelector = ".type"
    , subtypeSelector = ".subtype"
  ;

  function initQuestionTypeMenus(){
    $("body").on("click", typeSelector, function(event){
      var menu = $(this) ;

      if(menu.hasClass("open")){
        menu.removeClass("open")
      }else{
        menu.addClass("open");
      }

    });
  }


  function closeMenuDropDowns(){
    $(dropdownSelector).each(function() {
      var menu = $(this);
      menu.removeClass("open").removeAttr("style");
      menu.find(".js-menu-toggle").removeClass("fa-caret-up").addClass("fa-caret-down");
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

        Airbo.Utils.ping("Tile Type Selected", {
          type: config.type,
          subtype: config.subtype,
        });

      }
    })
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

