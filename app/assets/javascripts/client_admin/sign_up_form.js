//
//  =>  Sign up form
//
function creationStartCallback(event){ 
  $("#submit_account_form").attr("disabled", "disabled");
  $('#create_account_form').find(".errors_field").text("");
}
function creationResponseCallback(event, data){
  $("#submit_account_form").removeAttr("disabled");
  if(data.status == 'success'){
    if( window.pathForActionAfterRegistration ){
      localStorage.setItem("pathForActionAfterRegistration", window.pathForActionAfterRegistration);
      window.location.href = window.location.href.match(/(.*)\?/i) ? window.location.href.match(/(.*)\?/i)[1] : window.location.href;
    }else{
      window.location.href = "/client_admin/tiles";
    }
  }else{
    $('#create_account_form').find(".errors_field").text(data.errors);
  }
}
$().ready(function(){
  $('#create_account_form').on('submit', creationStartCallback).on('ajax:success', creationResponseCallback);
})
//
//  =>  Tile preview page
//
function showSignUpModal(){
  $("#modal_link").click();
}

function closeSignUpModal(){
  $('#sign_up_modal').foundation('reveal', 'close');
}
/* This is full dompath but it doesn't work in tests because it's too long.
function dompath( element )
{
    var path = '';
    for ( ; element && element.nodeType == 1; element = element.parentNode )
    {
        var inner = $(element).children().length == 0 ? $(element).text() : '';
        var idSelector = $(element).attr("id") ? $(element).attr("id").trim().split(" ").join("#") : "";
        var classSelector = $(element).attr("class") ? $(element).attr("class").trim().split(" ").join(".") : "";
        var eleSelector = element.tagName.toLowerCase() + 
          ( (idSelector.length > 0) ? ("#" + idSelector) : "" ) +
          ( (classSelector.length > 0) ? ("." + classSelector) : "" ) +
          ((inner.length > 0) ? ':contains(\'' + inner + '\')' : '');
        path = ' ' + eleSelector + path;
    }
    return path;
}
*/
// this function returns only selectors for element
function dompath( element ){
  var inner = $(element).children().length == 0 ? $(element).text() : '';
  var idSelector = $(element).attr("id") ? $(element).attr("id").trim().split(" ").join("#") : "";
  var classSelector = $(element).attr("class") ? $(element).attr("class").trim().split(" ").join(".") : "";
  var eleSelector = element.tagName.toLowerCase() + 
    ( (idSelector.length > 0) ? ("#" + idSelector) : "" ) +
    ( (classSelector.length > 0) ? ("." + classSelector) : "" ) +
    ( (inner.length > 0) ? ':contains(\'' + inner + '\')' : '' );
  return eleSelector;
}

$().ready(function(){
  if(window.guestForTilePreview){
    $("#save_progress_button").text("Create Board");

    $(".close_sign_up_modal").click(function(){
      closeSignUpModal();
    });

    blockedElements = [ ".not_like_button", 
                        "a .copy_button",
                        "#random-tile-link", 
                        "#back-link", 
                        ".tag a", 
                        "#save_progress_button",
                        "#prev",
                        "#next"
                      ].join(", ")
    $(blockedElements).click( function(event){
      event.preventDefault();
      event.stopImmediatePropagation(); 
      window.pathForActionAfterRegistration = dompath(event.target);
      showSignUpModal();
      return false; // prevents default for remote calls
    });
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
})