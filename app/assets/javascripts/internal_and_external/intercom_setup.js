function bindIntercomSettings(email, created_at, name, user_id, user_hash, demo, client_admin) {
  // Notice the underscore: "_intercomSettings"
  // This because if we called it intercomSettings, no underscore, it'd
  // automatically push the user data to Intercom when we call loadIntercom,
  // and we want to wait on that until the user actually tries to open 
  // Intercom.
  window._intercomSettings = {
    app_id: 'iukuloq8',
    email: email,
    created_at: created_at,
    name: name,
    user_id: user_id,
    user_hash: user_hash,
    custom_data:{
      demo: demo
    }
  };

  if(client_admin) {
    window._intercomSettings.widget = {
      activator: '#IntercomDefaultWidget',
      label: 'Support',
      use_counter: true
    }
  }
}

function bootIntercomWhenReady() {
  var intercomBootInterval = setInterval(function () {
    if(typeof(Intercom) != 'undefined') {
      clearInterval(intercomBootInterval);
      Intercom('boot', window._intercomSettings);
    }
  }, 1000);
}

function openIntercom() {
  Intercom('boot', window._intercomSettings);
  Intercom('show');
}

function bindIntercomOpen(selector) {
  $(document).ready(function() {
    $(selector).on('click', function(event) {
      event.preventDefault();
      openIntercom();
    });
  });
}
