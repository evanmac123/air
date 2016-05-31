var Airbo = window.Airbo || {};

Airbo.DependentEmailForm = (function() {
  function initEvents() {
    $("form.dependent_email_form").submit(function(e) {
      e.preventDefault();
      $(this).ajaxSubmit({
        dataType: 'html',
        success: function(data, status, xhr) {
          $(".tile_main").html(data);
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
  }
  return {
    get: get
  }
}());
