Airbo.BoardsAndOrganizationMgr = (function(){

  function unlink(url){
    $.ajax({
      url: url,
      type: "PUT",
      data: {organization_id: nil}
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

      if(confirm("Are you sure")){
        doit();
      }
      //Airbo.Utils.approve("are you sure?", doit)
    });
  }

  function init(){
    debugger
    if($(".admin-demo").length>0){
      initLink();
    }
  }

return{
  init: init
};

}())
