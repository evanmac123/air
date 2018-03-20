var Airbo = window.Airbo || {};

Airbo.LeadContact = (function() {
  function openTab() {
    $(".tablinks").on("click", function() {
      $(".tablinks").removeClass("active");
      $(this).addClass("active");
      $(".tabcontent").hide();
      $("#" + $(this).data("target")).show();
    });
  }

  function initialTabs() {
    $(".tabcontent").hide();
    $("#pendingLeads").show();
    $("#pending-leads-link").addClass("active");
  }

  function init() {
    openTab();
    initialTabs();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".lead-contacts-container").length > 0) {
    Airbo.LeadContact.init();
  }
});

var fillRespondForm = function(leadContact) {
  $("#lead_contact_name").val(leadContact.name);
  $("#lead_contact_email").val(leadContact.email);
  $("#lead_contact_phone").val(leadContact.phone);
  $("#lead_contact_company").val(leadContact.company);
  $("#lead_contact_size").val(leadContact.company_size);
};
