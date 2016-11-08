
var Airbo = window.Airbo || {};

Airbo.TileRecommender = (function(){ 

  function action(event){
    link = $(event.target);
    link.hasClass("add") ? recommend(link) : cancel(link);
    event.preventDefault();
  }

  function initHandlers(){
    $("body").on("click", ".recommend", action);
  }

  function recommend(target){
    function update(){
      target.removeClass("add").addClass("remove");
      target.text("Unrecommend");
    }
    submit(target,"POST", {tile_id: target.data("tileId")}, update);
  }

  function cancel(target){
    function update(){
      target.removeClass("remove").addClass("add");
      target.text("Recommend");
    }
    submit(target,"DELETE", {id: target.data("tileId")}, update);
  }

  function submit(target, type, data, callback){
    target.hide();
    target.siblings(".processing").show();
    $.ajax({
      url: target.attr("href"),
      type: type,
      dataType: "json",
      data: data,
      success: function(data, status,xhr){
        callback();
        toggleLink(target, data, type);
      },
      error: function(jqXHR, text, error ){
        console.log(text);
      },
    });
  }

  function toggleLink(target, data, type){
    target.attr("href", data.path);
    target.data("id", data.id);
    target.show();
    target.siblings(".processing").hide();
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
