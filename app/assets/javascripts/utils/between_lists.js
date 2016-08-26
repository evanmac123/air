var Airbo = window.Airbo ||{};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.BetweenList= (function(){
    var left, right;

    function moveItems(origin, dest) {
      $(origin).find(':selected').appendTo(dest);
      reSort(dest);
    }

    function moveAllItems(origin, dest) {
      $(origin).children().appendTo(dest);
    }

    function reSort(select){
      var options = select.children("option");
      options.sort(function(a,b) {
        var atext =a.text.toUpperCase()
          , btext =b.text.toUpperCase() 
        ;

        if (atext > btext) return 1;
        if (atext < btext) return -1;
        return 0
      })

      $(select).empty().append( options )
    }

    function initActions(){
      $('.move-right').on('click', function () {
        moveItems(left, right);
      });

      $('.move-left').click(function () {
        moveItems(right, left);
      });

      //$('.leftall').on('click', function () {
        //moveAllItems(right, left);
      //});

      //$('.rightall').on('click', function () {
        //moveAllItems(left, right);
      //});


          }

  function init(l, r){
    left= $(".left-list");
    right= $(".right-list");

    reSort(left);
    initActions();
  }

  return {
    init: init,
  }
}());

$(function(){
  Airbo.Utils.BetweenList.init();
});
