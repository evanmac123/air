var Airbo = window.Airbo ||{}

Airbo.Utils = Airbo.Utils || {}
Airbo.Utils.StickyTable = (function(){
var $table
  function initTable(){
    $table.floatThead();
    $table = $('table.sticky');
  }

  function init(){
    initTable();
  }

  function reflow(){
    init();
  }

  return {
    init: init,
    reflow: reflow
  }

}());



