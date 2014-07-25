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
    //closeSignUpModal();
    //window.guestForTilePreview = false;
    //$("<a href='" + window.location.href + "'></a>")[0].click(); //location.reload();
    if( window.pathForActionAfterRegistration ){
      localStorage.setItem("pathForActionAfterRegistration", window.pathForActionAfterRegistration);
      location.reload();
    }else{
      window.location.href = "/client_admin/tiles";
    }
    //window.actionAfterClientAdminRegister.click();
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

$().ready(function(){
  if(window.guestForTilePreview){
    $("#save_progress_button").text("Create Board");

    blockedElements = [ ".not_like_button", 
                        //"#copy_tile_button", 
                        "a .copy_button",
                        "#random-tile-link", 
                        "#back-link", 
                        ".tag a", 
                        "#save_progress_button"
                      ].join(", ")
    $(blockedElements).click( function(event){
      event.preventDefault();
      window.pathForActionAfterRegistration = dompath(event.target);
      //localStorage.setItem("actionAfterClientAdminRegister", window.actionAfterClientAdminRegister);
      showSignUpModal();
      //console.log("false");
      return false; // prevents default for remote calls
    });
  }
  //action after registration
  domPath = localStorage.getItem("pathForActionAfterRegistration") || "";
  if( domPath.length > 0 ){
    actionElement = $( domPath );
    localStorage.setItem("pathForActionAfterRegistration", "");
    actionElement[0].click();
  }
})