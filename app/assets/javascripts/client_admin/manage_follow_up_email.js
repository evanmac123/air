var Airbo = window.Airbo || {}


Airbo.DigestEmailFollowUpManager = (function(){
  var cmdSelector = ".commands .button"
  ;


  function initCommands(){

    $(cmdSelector).on("click", function(event){
      event.preventDefault();

      var cmd = $(this)
        , row = $(this).parents("tr")
        , inputs = row.find("input")
      ;

      switch(cmd.data("action")){
        case "edit":
          edit(cmd, inputs);
        break
        case "save":
          save(cmd, inputs );
        break;
        case "cancel":
          cancel(cmd, inputs );
        break;
        case "now":
          now(cmd);
        break;
        case "destroy":
          destroy(cmd);
        break;
      }
    });
  }


  function toggleEditMode(cmd, inputs){
    var hiddenCmdCss
      , disableEditing
    ;

    if(cmd.hasClass("edit")) {
      hiddenCmdCss = ".save, .cancel"
      visibleCmdCss = ".now, .destroy"
      disableEditing=false; 
    }else{
      hiddenCmdCss = ".edit, .now, .destroy";
      visibleCmdCss = ".save, .cancel"
      disableEditing=true; 
    }

    cmd.hide();
    cmd.siblings(hiddenCmdCss).show();
    cmd.siblings(visibleCmdCss).hide();
    inputs.prop("disabled", disableEditing);
  }

  function execute(meth, url, data, success, fail){
    $.ajax({
      type: meth,
      url: url,
      data: data 
    })
    .done(success)
    .fail(fail)
  }
 

  function handleRemoval(cmd){
    var tableBody = cmd.parents("tbody");
    cmd.parents("tr").remove();

    if (tableBody.children("tr:not(.no-follow-up)").length == 0){
      tableBody.children("tr.no-follow-up").show();
    }
  }

  function restoreValues(inputs){
    inputs.each(function(index, input){
      var $input =  $(input);
      $input.val($input.data("original-val"));
    }) 
  }


  function edit(cmd, inputs){
    toggleEditMode(cmd, inputs)
  }

  function save(cmd, inputs){
    function ok(data, status, xhr){
      toggleEditMode(cmd,inputs)
      console.log("saved");
    }

    function failed(xhr, status, error){
    }

    execute("PUT", cmd.attr("href"), inputs.serialize(), ok, failed);
  }


  function now(cmd){
    function ok(data, status, xhr){
      handleRemoval(cmd)
    }

    function failed(){
      console.log("unabled to send now");
    }

    execute("PUT", cmd.attr("href"), {now: "true"}, ok, failed);
  }

  function destroy(cmd){
    function ok(data, status, xhr){
      handleRemoval(cmd)
      Airbo.Utils.ping("Followup - Cancelled", data)
    }

    execute("DELETE", cmd.attr("href"),{}, ok);

  }

  function cancel(cmd, inputs){
    toggleEditMode(cmd,inputs)
    restoreValues(inputs)
  }


  function init(){
    initCommands();
  }
  

  return {
    init: init,
  }

}());

$(function(){
  Airbo.DigestEmailFollowUpManager.init();
})
