var Airbo = window.Airbo || {};

Airbo.AjaxResponseHandler = (function(){
  function isFunction(possibleFunction) {
    return (typeof(possibleFunction) == typeof(Function));
  }

  function silentSuccess(data, textStatus, xhr, callback){
    silentStationarySuccess(data, textStatus, xhr, callback);
    redirect_to(xhr.getResponseHeader("location"));
  }

  function silentStationarySuccess(data, textStatus, xhr, callback){
    handle(callback, xhr, data);
  }

  function stationarySuccess(data, textStatus, xhr, callback){
    flash("success", getMessage(xhr, "Request Completed Successfully"));
    silentStationarySuccess(data, textStatus, xhr, callback);
  }

  function success(data, textStatus, xhr, callback){
    flash("success", getMessage(xhr, "Request Completed Successfully"));
    silentSuccess(data, textStatus, xhr, callback);
  }

  function fail(xhr, textStatus,callback){
    flash("error", getMessage(xhr, "Request Failed"));
    handle(callback, xhr);
  }

  function getMessage(xhr, defaultMsg){
    return xhr.getResponseHeader("X-Message") || defaultMsg;
  }

  function handle(callback, xhr, data){
    if(isFunction(callback)){
      callback(data);
    }
  }

  function redirect_to(path){
    if(path !==null && path !==undefined){
      window.location.href = path;
    }
  }

  function flash(type, msg){
    Airbo.Utils.noop
  }

  function submit(form, successCallback, failCallBack){
    $.ajax({
      url: form.attr("action"),
      type: form.attr("method"),
      data: form.serialize(),
    }).done(function(data,status,xhr){

      silentSuccess(data, status, xhr, function(data){
        successCallback(data)
      });

    }).fail(function(xhr, status, errorThrown){
      fail( xhr, status, function(){
        failCallBack(status);
      });

    });
  }

  //#TODO there's a hidden designer or architecture pattern here figure it out. 
  //Should this be a promise interface or should i just expose properties like suppress_redirect?
  return {
    submit: submit,
    success: success,
    fail: fail,
    silentSuccess: silentSuccess,
    silentStationarySuccess: silentStationarySuccess,
    stationarySuccess:stationarySuccess
  };

})();
