var Airbo = window.Airbo || {};

Airbo.DependentEmailForm = (function() {
  var deferred;
  function initEvents() {
    $("form.dependent_email_form").submit(function(e) {
      e.preventDefault();
      $(this).ajaxSubmit({
        dataType: 'html',
        success: function(data, status, xhr) {
          $(".tile_main").html(data);
          deferred.resolve();
        }
      });
    });
  }
  function get() {
    $.ajax({
      type: "GET",
      url: '/invitation/dependent_user_invitation/new',
      dataType: "html",
      success: function(data, status, xhr) {
        $(".tile_main").html(data);
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
