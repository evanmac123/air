var Airbo = window.Airbo || {}


Airbo.DigestEmailFollowUpManager = (function(){
  var cmdSelector = "td.actions>a ";
  var currRow;

  /*
   *******************************
   * Modal Popup Form
   *
   ******************************
  */

  var modal = (function(){

    var modalId = "manage_follow_up"
      , modalObj = Airbo.Utils.StandardModal()
      , form
      , validator
    ;


    function initPreviewElements() {
      initEvents();
    }

    function save(cmd){

      function ok(data, status, xhr){
        done("success", xhr);
        update(data);
      }

      function failed(xhr, status, error){
      }

      execute("PUT", cmd.attr("href"), cmd.parents("form").serialize(), ok, failed);
    }

    function initSave(){
      $(".button.save").on("click", function(event){
        event.preventDefault();
        save($(this));
      });
    }

    function initForm(){
      form = $(".edit_follow_up_digest_email");
      $("#follow_up_digest_email_send_on").datepicker(
        {
          dateFormat: "DD, MM dd, yy"
        }
      );
    }


    function open(url) {
      $.ajax({
        type: "GET",
        dataType: "html",
        url: url,
        success: function(data, status,xhr){
          modalObj.setContent(data);
          modalObj.open();
          initSave();
          initForm();
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    }


    function initModalObj() {
      modalObj.init({
        modalId: modalId,
        useAjaxModal: true,
      });
    }

    function init(){
      initModalObj();
      return this;
    }

    return {
      init: init,
      open: open,
      close: modalObj.close,
      modalId: modalId
    }
  }());


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

  function edit(cmd){
    modal.open(cmd.attr("href"));
  }

  function now(cmd){
    function ok(data, status, xhr){
      handleRemoval()
      done("success", xhr);
    }

    function failed(){
      console.log("unabled to send now");
    }

    approve("Are you sure want to send this follow up immediately?", function(){
      execute("PUT", cmd.attr("href"), {now: "true"}, ok, failed);
    });
  }

  function destroy(cmd){
    function ok(data, status, xhr){
      handleRemoval()
      done("success",xhr);
      Airbo.Utils.ping("Followup - Cancelled", data)
    }

    approve("Are you sure want to delete this followup email?", function(){
      execute("DELETE", cmd.attr("href"),{}, ok);
    });
  }

  function initCommands(){
    $(cmdSelector).on("click", function(event){
      event.preventDefault();

      var cmd = $(this);
      currRow = cmd.parents("tr")

      switch(cmd.data("action")){
        case "edit":
          edit(cmd);
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


  function done(type, xhr){
    //TODO modify to use status from xhr instead of passing in status
    var msg = xhr.getResponseHeader("X-Message") || "Request Completed Successfully";
    modal.close();
    Airbo.Utils.flash(type, msg);
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

  function handleRemoval(){
    var tableBody = currRow.parents("tbody");
    currRow.remove();
    if (tableBody.children("tr:not(.no-follow-up)").length == 0){
      $("#schedule_followups").hide();
    }
  }

  function update(data){
    var date = $.datepicker.parseDate("yy-mm-dd", data["send_on"]),
      subject = Airbo.Utils.truncate(data["original_digest_subject"], 50)
    ; 
    currRow.find("td.subject>span").text(subject);
    currRow.find("td.send_on").text($.datepicker.formatDate("DD, MM d, yy",date));
  }



  function init(){
    modal.init();
    initCommands();
  }

  return {
    init: init,
  }

}());

$(function(){
  Airbo.DigestEmailFollowUpManager.init();
})


