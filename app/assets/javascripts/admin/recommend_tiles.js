
var Airbo = window.Airbo || {};

Airbo.TileRecommender = (function(){ 

  function initHandlers(){
    function action(link){
      link.hasClass("add") ? recommend(link) : cancel(link);
    }

    $("body").on("click", ".recommend", function(event){
      event.preventDefault();
      action($(this))
    })
  }

  function recommend(target){
    target.removeClass("add").addClass("remove");
    target.text("Unrecommend");
    submit(target,"POST", {tile_id: target.data("tileId")});
  }

  function cancel(target){
    target.removeClass("remove").addClass("add");
    target.text("Recommend");
    submit(target,"DELETE", {id: target.data("tileId")});
  }

  function submit(target, type, data){
    $.ajax({
      url: target.attr("href"),
      type: type,
      dataType: "json",
      data: data,
      success: function(data, status,xhr){
        toggleLink(target, data, type);
      },
      error: function(){}
    });
  }

  function toggleLink(target, data, type){
    target.attr("href", data.path);
    target.data("id", data.id);
  }



  function init(){
    initHandlers();
  }




  return {
    init: init
  };

})();



$(function(){
 Airbo.TileRecommender.init();
})
