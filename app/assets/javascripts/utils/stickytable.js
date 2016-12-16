var Airbo = window.Airbo ||{}

Airbo.Utils = Airbo.Utils || {}
Airbo.Utils.StickyTable = (function(){
  var $table
  function initTable(){
    $table = $('table.sticky');
    $table.floatThead(
      {
        position: 'absolute',
      }
    );
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



