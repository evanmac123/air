$(function(){
 var ajaxHandler = Airbo.AjaxResponseHandler;

 function toggleSubmit(button){
   button.attr('disabled', 'disabled');
 }

 $("body").on("submit", "#new_tile_builder_form", function(event){
  event.preventDefault(); 
  form = $(this);
  submitButton = form.find('input[type=submit]')
  submitButton.attr("disabled", "disabled");
  
  if((form).data("asAjax")==true){
    $.ajax({
      url: form.attr("action"),
      type: form.attr("method"),
      data: form.serialize(),
    }).done(function(data,status,xhr){
        ajaxHandler.silentSuccess(data, status, xhr, function(){

        });

    }).fail(function(xhr, status, errorThrown){
      ajaxHandler.fail(status, xhr, function(){
        alert("failed");
        submitButton.removeAttr("disabled");
      });

    });
  }else {
     form[0].submit();
  }

 });



});
