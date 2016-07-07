var Airbo = window.Airbo || {};

Airbo.SignUpFromPreview = (function(){
  var modalObj = Airbo.Utils.StandardModal()
    , modalId = "sign_up_modal"
    , blockedElements = [ ".see_airbo",
                          ".tag"
                        ].join(", ")
  ;
  function creationStartCallback(event){
    $("#submit_account_form").attr("disabled", "disabled");
    $('#create_account_form').find(".errors_field").text("");
  }
  function creationResponseCallback(event, data){
    $("#submit_account_form").removeAttr("disabled");
    if(data.status == 'success'){
      if( window.pathForActionAfterRegistration ){
        localStorage.setItem("pathForActionAfterRegistration", window.pathForActionAfterRegistration);
        location.reload();
        // window.location.href = window.location.href.match(/(.*)\?/i) ? window.location.href.match(/(.*)\?/i)[1] : window.location.href;
      }else{
        window.location.href = "/client_admin/tiles";
      }
    }else{
      $('#create_account_form').find(".errors_field").text(data.errors);
    }
  }
  function dompath( element ){
    var inner = $(element).children().length == 0 ? $(element).text() : '';
    var idSelector = $(element).attr("id") ? $.trim($(element).attr("id")).split(" ").join("#") : "";
    var classSelector = $(element).attr("class") ? $.trim($(element).attr("class")).split(" ").join(".") : "";
    var eleSelector = element.tagName.toLowerCase() +
      ( (idSelector.length > 0) ? ("#" + idSelector) : "" ) +
      ( (classSelector.length > 0) ? ("." + classSelector) : "" ) +
      ( (inner.length > 0) ? ':contains(\'' + inner + '\')' : '' );
    return eleSelector;
  }
  function initEvents() {
    $(blockedElements).click( function(event){
      event.preventDefault();
      event.stopImmediatePropagation();
      window.pathForActionAfterRegistration = dompath(event.target);
      modalObj.open();
      return false; // prevents default for remote calls
    });

    $('#create_account_form').on('submit', creationStartCallback).on('ajax:success', creationResponseCallback);
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId
    });
  }
  function init() {
    initModalObj();
    initEvents();
  }
  return {
    init: init
  }
}());

$(document).ready(function(){
  if( $(".single_tile_guest_layout").length > 0 ) {
    Airbo.SignUpFromPreview.init();
  }
  //action after registration
  domPath = localStorage.getItem("pathForActionAfterRegistration") || "";
  if( domPath.length > 0 ){
    actionElement = $( domPath );
    localStorage.setItem("pathForActionAfterRegistration", "");
    if(actionElement.length > 0){
      actionElement[0].click();
    }
  }
});
