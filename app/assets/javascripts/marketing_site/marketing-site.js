var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Base = (function() {
  function generateDemoRequestForm() {
    var formEl = document.createElement("div");
    formEl.style.textAlign = "left";
    formEl.innerHTML =
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
      '<p class="terms" id="t-and-c-notice" style="font-size: 10px;">By submitting this form or using this site, you are agreeing to the <a href="/pages/terms" target="_blank">terms and conditions</a></p>';
    return formEl;
    // <%= hidden_field_tag "lead_contact[source]", "Inbound: Demo Request" %>
  }

  function generateLoginForm() {
    var formEl = document.createElement("div");
    formEl.innerHTML =
      '<input type="text" placeholder="Email Address" name="session[email]" id="session_email">' +
      '<input type="password" placeholder="Password" name="session[password]" id="session_password">' +
      '<div class="wrap" style="float: left;">' +
      '<input style="margin: 0 5px;" type="checkbox" name="session[remember_me]" id="session_remember_me" value="1" checked="checked" class="hidden-field"><span class="custom checkbox checked"></span>' +
      '<label class="inline" for="session_remember_me">Remember me</label>' +
      "</div>" +
      '<a id="set_or_reset_password" href="/passwords/new" style="float: right;">Set or Reset Your Password</a>';
    return formEl;
  }

  function triggerDemoRequestModal(e) {
    e.preventDefault();
    var demoRequestForm = generateDemoRequestForm();
    swal({
      title: "Schedule a Demo",
      text:
        "We’ll email you within the next few hours to schedule a 30 minute overview.",
      content: demoRequestForm,
      buttons: ["Cancel", "Submit"]
    });
  }

  function triggerLoginModal(e) {
    e.preventDefault();
    var loginForm = generateLoginForm();
    swal({
      title: "Sign In",
      content: loginForm,
      buttons: ["Cancel", "Sign In"]
    });
  }

  function init() {
    $(".js-request-demo").click(triggerDemoRequestModal);
    $(".js-login").click(triggerLoginModal);
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
