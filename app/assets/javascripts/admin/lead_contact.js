var Airbo = window.Airbo || {};

Airbo.LeadContact = (function(){
  function initRespondButton(){
    $('.lead-contact-respond').on("click", function(e){
      e.preventDefault();
      $('#lead-contact-respond-modal').foundation('reveal', 'open');

      var leadContact = $(this).data("leadContact");
      fillRespondForm(leadContact);
    });
  }

  function toggleOrganizationInputs() {
    $('#lead_contact_new_organization').change(function() {
      if(this.checked) {
        $(".match-organization").hide();
        $("#lead_contact_matched_organization").prop( "disabled", true );
        $("#lead_contact_organization_name").prop( "disabled", false );
        $("#lead_contact_organization_size").prop( "disabled", false );
        $(".new-org-options").show();
      } else {
        $(".match-organization").show();
        $("#lead_contact_matched_organization").prop( "disabled", false );
        $("#lead_contact_organization_name").prop( "disabled", true );
        $("#lead_contact_organization_size").prop( "disabled", true );
        $(".new-org-options").hide();
      }
    });
  }

  function showFullRespondForm() {
    $('.respond-form-second-part').show();
  }

  function initCloseAdminModal() {
    $('.admin-close-modal').on("click", function(e){
      e.preventDefault();
      $(this).parent().foundation('reveal', 'close');
    });
  }

  function initDynamicModelLaunch() {
    $("#lead-contacts-approval-modal").foundation('reveal', 'open');
  }

  function initOrgSearch() {
    $("#org-search").on("click", function(e) {
      e.preventDefault();
      runSearch();
    });

    $("#org-search-input").keyup(function(e) {
      if (event.keyCode == 13) {
        runSearch();
      }
    });
  }

  function runSearch() {
    if ($("#org-search-input").val() === "") {
      $(".organization").hide();
      $(".organization-search-helper").hide();
    } else {
      orgSearch($("#org-search-input").val());
      if ($(".organization:visible").length > 0) {
        $(".organization-search-helper").show();
      } else {
        $(".organization-search-helper").hide();
      }
    }
  }

  function orgSearch(query) {
    $(".organization").each(function() {
      $(this).show();
      var name = $(this).data("name").toLowerCase();
      var match = searchDemo(query, [name]);
      if (match.indexOf(true) === -1) {
        $(this).toggle();
      }
    });
  }

  function searchOrgs(query, entries) {
    return entries.map(function(entry){
      if (entry.indexOf(query.toLowerCase()) === -1) {
        return false;
      } else {
        return true;
      }
    });
  }

  function matchExistingOrg() {
    $(".organization").on("click", function() {
      $("#lead_contact_matched_organization").val($(this).data("name"));
      $("#lead_contact_matched_organization").css("background", "rgba(70, 200, 125, 0.2)");
    });
  }

  function initPrioritySelection() {
    $(".topic_cell").on("click", function() {
      $(".topic_cell").removeClass("selected");
      $(this).addClass("selected");
      $("#board_template").val($(this).data("boardName"));
      $("#board_template_id").val($(this).data("boardId"));
      $(".lead-board-details").show();
    });
  }

  function initApproveValidations() {
    $("#approve-lead-contact").on("click", function(event) {
      $("#lead_contact_matched_organization").prop('readonly', false);
      var form = $(this).parent();
      var config = {
        onkeyup: false,
        rules: {
          "lead_contact[matched_organization]": {
            required: true,
            minlength: 2
          },
        },
        messages: {
          "lead_contact[matched_organization]": {
            required: "Select and existing organization before approval.",
          },
        },
        errorPlacement: function(error, element) {
          var placement = $(element).data('error');
          if (placement) {
            $(placement).append(error);
          } else {
            error.insertAfter(element);
          }
        }
      };

      config = $.extend({}, Airbo.Utils.validationConfig, config);
      var validator = form.validate(config);

      if(!form.valid()){
        event.preventDefault();
        validator.focusInvalid();
        $("#lead_contact_matched_organization").prop('readonly', true);
      }
    });
  }


  function init() {
    initOrgSearch();
    initRespondButton();
    toggleOrganizationInputs();
    matchExistingOrg();
    initApproveValidations();
    initCloseAdminModal();
    initDynamicModelLaunch();
    initPrioritySelection();
  }

  return {
  init: init
};
}());

$(function(){
  Airbo.LeadContact.init();
});

var fillRespondForm = function(leadContact) {
  $("#lead_contact_name").val(leadContact.name);
  $("#lead_contact_email").val(leadContact.email);
  $("#lead_contact_phone").val(leadContact.phone);
  $("#lead_contact_company").val(leadContact.company);
  $("#lead_contact_size").val(leadContact.company_size);
};
