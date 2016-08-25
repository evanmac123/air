var Airbo = window.Airbo ||{};
Airbo.Utils = Airbo.Utils || {};
Airbo.Utils.BetweenList= (function(){
    var left, right;

    function moveItems(origin, dest) {
      $(origin).find(':selected').appendTo(dest);
    }

    function moveAllItems(origin, dest) {
      $(origin).children().appendTo(dest);
    }

    function initActions(){
      $('.left').click(function () {
        moveItems(right, left);
      });

      $('.right').on('click', function () {
        moveItems(left, right);
      });

      $('.leftall').on('click', function () {
        moveAllItems(right, left);
      });

      $('.rightall').on('click', function () {
        moveAllItems(left, right);
      });
    }

  function init(l, r){
    left= $(l);
    right= $(r);
    initActions();
  }

  return {
    init: init,
  }
}());


