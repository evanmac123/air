var Airbo = window.Airbo ||{}

Airbo.Utils = Airbo.Utils || {}
Airbo.Utils.StickyTable = (function(){

  function initTable(){
    var $table = $('table.sticky');
    $table.floatThead();
  }

  function init(){
    initTable();
  }

  return {
    init: init
  }

}());


$(function(){
  Airbo.Utils.StickyTable.init();
})

