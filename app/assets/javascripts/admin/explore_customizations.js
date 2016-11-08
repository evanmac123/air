var Airbo = window.Airbo || {};

Airbo.ExploreCustomizations = (function(){
  function initForm() {
    $(".explore-customizations-button").on("click", function(e) {
      var self = $(this);
      var form = self.parents("form");
      submitForm(form, self);
    });
  }

  function submitForm(form, self) {
    Airbo.Utils.ButtonSpinner.trigger(self);
    $.post( form.attr("action"), form.serialize()).done(function(data) {
      if (data.errors) {
        Airbo.Utils.ButtonSpinner.completeError(self);
      } else {
        Airbo.Utils.ButtonSpinner.completeSuccess(self, true);
      }
    });
  }


  function init() {
    initForm();
  }

  return {
    init: init
  };
}());

$(function() {
  if ($(".admin-explore_customizations-new").length > 0) {
    Airbo.ExploreCustomizations.init();
  }
});
