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


  function approve(text, cb) {
    swal(
      {
        title: "",
        text: text,
        cancelButtonText: "Cancel",
        animation: false,
        customClass: "airbo",
        closeOnConfirm: true,
        showCancelButton: true,
        closeOnCancel: true
      },

      function(isConfirm){
        if (isConfirm) {

          cb &&cb();
        }
      }
    );
  }

  function done(type, xhr){
    //TODO modify to use status from xhr instead of passing in status
    var msg = xhr.getResponseHeader("X-Message") || "Request Completed Successfully";
    Airbo.Utils.flash(type, msg);
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
      done("success", xhr);
    }

    function failed(xhr, status, error){
    }

    execute("PUT", cmd.attr("href"), inputs.serialize(), ok, failed);
  }


  function now(cmd){
    function ok(data, status, xhr){
      handleRemoval(cmd)
      done("success", xhr);
    }

    function failed(){
      console.log("unabled to send now");
    }

    approve("Are you sure want to sen this followup immediately?", function(){
      execute("PUT", cmd.attr("href"), {now: "true"}, ok, failed);
    });
  }

  function destroy(cmd){
    function ok(data, status, xhr){
      handleRemoval(cmd)
      done("success",xhr);
      Airbo.Utils.ping("Followup - Cancelled", data)
    }

    approve("Are you sure want to delete this followup email?", function(){
      execute("DELETE", cmd.attr("href"),{}, ok);
    });

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
