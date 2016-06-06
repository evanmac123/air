var Airbo = window.Airbo || {};

Airbo.DependentEmailForm = (function() {
  var deferred
    , formSel = "form.dependent_email_form"
    , noInviteLinkSel = formSel + " .no_invitation"
    , tileMainSecSel = ".tile_main"
  ;
  function initEvents() {
    $(formSel).submit(function(e) {
      e.preventDefault();
      $(this).ajaxSubmit({
        dataType: 'html',
        success: function(data, status, xhr) {
          $(formSel).html(data);
          setTimeout(deferred.resolve, 1000);
        }
      });
    });

    $(noInviteLinkSel).click(function(e) {
      e.preventDefault();
      deferred.reject();

      $(tileMainSecSel).show();
      $(formSel).hide();
    });
  }
  function get() {
    $.ajax({
      type: "GET",
      url: '/invitation/dependent_user_invitation/new',
      dataType: "html",
      success: function(data, status, xhr) {
        $(tileMainSecSel).hide().after(data);
        initEvents();
      }
    });

    deferred = $.Deferred();
    return deferred.promise();
  }
  return {
    get: get
  }
}());
