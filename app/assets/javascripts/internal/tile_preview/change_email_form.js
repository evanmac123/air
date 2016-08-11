var Airbo = window.Airbo || {};

Airbo.ChangeEmailForm = (function() {
  var deferred
    , formSel = "form.change_email_form"
    , exitFormSel = formSel + " .no_email_change"
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
            setTimeout(deferred.resolve, 5000);
          },
          error: function(data, status, xhr) {
            $(".change_email_error").show().text(data.responseText);
          },
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
      rules: {
        "change_email[email]":{
          required: true,
          email: true
        }
      },
      errorElement : 'label',
      errorLabelContainer: '.change_email_error'
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
      url: '/change_email/new',
      dataType: "html",
      success: function(data, status, xhr) {
        $(tileQuizSecSel).hide().after(data);
        init();

        $("#change_email_email").focus();

        var tileId = $(".tile_holder").data("current-tile-id");
        Airbo.Utils.ping('Opened Email Change Form', {tile_id: tileId});
      }
    });

    deferred = $.Deferred();
    return deferred.promise();
  }
  return {
    get: get
  }
}());