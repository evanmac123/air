var Airbo = window.Airbo || {};

Airbo.DependentEmailForm = (function() {
  var deferred
    , formSel = "form.dependent_email_form"
    , exitFormSel = formSel + " .no_invitation"
    , tileQuizSecSel = ".multiple_choice_group"
    , form
  ;

  function initEvents() {
    form.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if(formObj.valid()){
       formObj.ajaxSubmit({
          dataType: 'html',
          success: function(data, status, xhr) {
            $(formSel).replaceWith(data);
            setTimeout(deferred.resolve, 1000);
          }
        });
      }else{
       console.log("invalid form");
      }

    });

    $(exitFormSel).click(function(e) {
      e.preventDefault();
      deferred.reject();

      $(tileQuizSecSel).show();
      form.hide();
    });
  }

  function initValidator(){
    var config = {

    errorClass: "dependent_user_invitation_error",
      rules: {
    "dependent_user_invitation[email]":{ required: true },
    "dependent_user_invitation[subject]": { required: true },
    "dependent_user_invitation[body]": { required: true }
      },
      messages: {
        "dependent_user_invitation[email]": "Email is required",
        "dependent_user_invitation[subject]": "Subject is required",
        "dependent_user_invitation[body]": "Email body is required"
      },

      errorPlacement: function(error, element) {
        error.insertAfter(element);
      }
    },


    config = $.extend({}, Airbo.Utils.validationConfig, config);
    return form.validate(config);
  }

  function init(){
    form = $(formSel);
    initValidator();
    initEvents();
  }

  function get() {
    $.ajax({
      type: "GET",
      url: '/invitation/dependent_user_invitation/new',
      dataType: "html",
      success: function(data, status, xhr) {
        $(tileQuizSecSel).hide().after(data);
        init();

        var tileId = $(".tile_holder").data("current-tile-id");
        Airbo.Utils.ping('Opened Invite Form', {tile_id: tileId});
      }
    });

    deferred = $.Deferred();
    return deferred.promise();
  }
  return {
    get: get
  }
}());
