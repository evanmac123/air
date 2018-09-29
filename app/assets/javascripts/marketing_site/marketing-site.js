var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Base = (function() {
  function allFieldsValid(vals) {
    for (var i = 0; i < Object.keys(vals).length; i++) {
      if (!vals[Object.keys(vals)[i]]) {
        return false;
      }
    }
    return true;
  }

  function getValues(param, docIds) {
    var result = {};
    result[param] = {};
    result[param].marketing = true;
    docIds.forEach(function(id) {
      var elem = document.getElementById(param + "_" + id);
      result[param][id] =
        id === "remember_me" ? "" + elem.checked + "" : elem.value;
    });
    return result;
  }

  function generateEmailForm() {
    var formEl = document.createElement("div");
    formEl.innerHTML =
      '<input type="text" name="password[email]" id="password_email" value="" placeholder="Email address">';
    return formEl;
  }

  function generateDemoRequestForm(errors) {
    var formEl = document.createElement("div");
    formEl.style.textAlign = "left";
    formEl.innerHTML =
      (errors
        ? '<p style="color: red;">Please fill in all fields to submit a demo</p>'
        : "") +
      '<label class="input_label">Full name</label>' +
      '<input type="text" name="lead_contact[name]" id="lead_contact_name" autofocus>' +
      '<label class="input_label">Email address</label>' +
      '<input type="text" name="lead_contact[email]" id="lead_contact_email">' +
      '<label class="input_label">Phone number</label>' +
      '<input type="text" name="lead_contact[phone]" id="lead_contact_phone">' +
      '<label class="input_label">Company name</label>' +
      '<input type="text" name="lead_contact[organization_name]" id="lead_contact_organization_name">' +
      '<label class="input_label">Company size</label>' +
      '<select name="lead_contact[organization_size]" id="lead_contact_organization_size"><option value="less than 100 employees">less than 100 employees</option>' +
      '<option value="100-500 employees">100-500 employees</option>' +
      '<option value="500-1000 employees">500-1000 employees</option>' +
      '<option value="1000-5000 employees">1000-5000 employees</option>' +
      '<option value="more than 5000 employees">more than 5000 employees</option>' +
      "</select>" +
      '<input type="hidden" name="lead_contact[source]" id="lead_contact_source" value="Inbound: Demo Request">' +
      '<p class="terms" id="t-and-c-notice" style="font-size: 10px;">By submitting this form or using this site, you are agreeing to the <a href="/pages/terms" target="_blank">terms and conditions</a></p>';
    return formEl;
  }

  function generateLoginForm(errors) {
    var formEl = document.createElement("div");
    formEl.innerHTML =
      (errors
        ? '<p style="color: red;">Sorry, that\'s an invalid username or password.</p>'
        : "") +
      '<input type="text" placeholder="Email Address" name="session[email]" id="session_email">' +
      '<input type="password" placeholder="Password" name="session[password]" id="session_password">' +
      '<div class="wrap" style="float: left;">' +
      '<input style="margin: 0 5px;" type="checkbox" name="session[remember_me]" id="session_remember_me" value="1" checked="checked" class="hidden-field"><span class="custom checkbox checked"></span>' +
      '<label class="inline" for="session_remember_me">Remember me</label>' +
      "</div>" +
      '<a id="set_or_reset_password" style="float: right;">Set or Reset Your Password</a>';
    return formEl;
  }

  function triggerDemoRequestModal(e, errors) {
    e.preventDefault();
    closeMenu(e);
    var demoRequestForm = generateDemoRequestForm(errors);
    swal({
      title: "Schedule a Demo",
      text:
        "We’ll email you within the next few hours to schedule a 30 minute overview.",
      content: demoRequestForm,
      buttons: {
        cancel: "Cancel",
        submit: {
          text: "Submit",
          value: "submit",
          closeModal: false
        }
      }
    })
      .then(function(submit) {
        if (submit) {
          var vals = getValues("lead_contact", [
            "name",
            "email",
            "phone",
            "organization_name",
            "organization_size",
            "source"
          ]);
          if (allFieldsValid(vals["lead_contact"])) {
            $.ajax({
              type: "POST",
              url: "/demo_requests/marketing",
              data: vals,
              success: function(resp) {
                if (resp.duplicate) {
                  swal(
                    "An Airbo account has already been requested",
                    "Someone from our team will reach out to you shortly.",
                    "success"
                  );
                } else {
                  swal(
                    "Demo Request Sent",
                    "Someone from our team will reach out to you in the next 24 hours to schedule a time to chat.",
                    "success"
                  );
                }
              }
            });
          } else {
            triggerDemoRequestModal(e, "errors");
          }
        }
      })
      .catch(function() {
        triggerDemoRequestModal(e, "errors");
      });
  }

  function triggerLoginModal(e, errors) {
    if (e) {
      e.preventDefault();
    }
    closeMenu(e);
    var loginForm = generateLoginForm(errors);
    swal({
      title: "Sign In",
      content: loginForm,
      buttons: {
        cancel: "Cancel",
        submit: {
          text: "Sign In",
          value: "submit",
          closeModal: false
        }
      }
    })
      .then(function(submit) {
        if (submit) {
          var vals = getValues("session", ["email", "password", "remember_me"]);
          if (allFieldsValid(vals["session"])) {
            $.ajax({
              headers: {
                "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
              },
              type: "POST",
              url: "/session",
              data: vals,
              success: function(resp) {
                if (resp.not_found) {
                  triggerLoginModal(e, "errors");
                } else {
                  window.location = resp.path;
                }
              }
            });
          } else {
            triggerLoginModal(e, "errors");
          }
        }
      })
      .catch(function() {
        triggerLoginModal(e, "errors");
      });
  }

  function resetPassword(e) {
    e.preventDefault();
    var emailForm = generateEmailForm();
    swal({
      title: "Reset Password",
      text: "We will email you a link to reset your password",
      content: emailForm,
      buttons: {
        submit: {
          text: "Reset Password",
          value: "submit",
          closeModal: false
        }
      }
    }).then(function(submit) {
      if (submit) {
        var vals = getValues("password", ["email"]);
        if (allFieldsValid(vals["password"])) {
          $.ajax({
            headers: {
              "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content")
            },
            type: "POST",
            url: "/passwords",
            data: vals,
            success: function(resp) {
              if (resp.success) {
                swal(
                  "Processing your reset password request",
                  "Please check your email shortly for more information.",
                  "success"
                );
              } else {
                swal("Something went wrong", resp.fail, "warning");
              }
            }
          });
        } else {
          resetPassword(e, "errors");
        }
      }
    });
  }

  function toggleHamburgerMenu(e, close) {
    var $drawer = $(".drawer");
    var display = close ? "" : "none !important";
    $(".u-hamburger").attr("style", "display: " + display);
    $(".drawer").toggleClass("open-drawer");
    $(".main").toggleClass("open-wrapper");
    $(document).on("click", ".main.open-wrapper", closeMenu);
  }

  function closeMenu(e) {
    var $drawer = $(".drawer");
    if ($drawer.attr("class").split(" ")[1] === "open-drawer") {
      toggleHamburgerMenu(e, "close");
    }
  }

  function locationParamsInclude(key, value) {
    if (window.location.href.split("?")[1]) {
      var splitParams = window.location.href.split("?")[1].split("&");
      for (var i = 0; i < splitParams.length; i++) {
        var splitParam = splitParams[i].split("=");
        if (splitParam[0] === key && splitParam[1]) {
          return true;
        }
      }
    }
  }

  function init() {
    Airbo.AiRouter.defineRoutes({
      root: { path: "/" },
      hello: {
        path: "/hello",
        title: "Airbo says HELLO"
      },
      privacy: {
        path: "/privacy_policy",
        title: "Airbo - Privacy Policy"
      },
      terms: {
        path: "/terms",
        title: "Airbo - Terms"
      }
    });

    $(".js-request-demo").click(triggerDemoRequestModal);
    $(".js-login").click(triggerLoginModal);
    $(document).on("click", "#set_or_reset_password", resetPassword);
    $(document).on("click", ".u-hamburger", toggleHamburgerMenu);
    if (locationParamsInclude("sign_in", "true")) {
      triggerLoginModal();
    }
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".airbo-marketing-site")) {
    Airbo.MarketingSite.Base.init();
  }
});
