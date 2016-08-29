Airbo.BoardsAndOrganizationMgr = (function(){

  function unlink(url){
    $.ajax({
      url: url,
      type: "PUT",
      data: {demo: {unlink: true}}
    })
    .done(function(){
      console.log("unlink worked");
    })
    .fail(function(){
      console.log("unlink failed");
    });
  }

  function initLink(){
    $(".admin-demo .unlink").click(function(event){
      event.preventDefault();
      var self = $(this);

      function doit(){
        unlink(self.attr("href"));
      }

      //TODO swich to sweetalert
      if(confirm("Are you sure")){
        doit();
      }
      //Airbo.Utils.approve("are you sure?", doit)
    });
  }

  function init(){
    if($(".admin-demo").length>0){
      initLink();
    }

    Airbo.Utils.initChosen();
  }

return{
  init: init
};

}())
