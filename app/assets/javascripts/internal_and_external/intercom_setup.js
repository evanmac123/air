function bindIntercomSettings(email, created_at, name, user_id, user_hash, demo) {
  window.intercomSettings = {
    app_id: 'iukuloq8',
    email: email,
    created_at: created_at,
    name: name,
    user_id: user_id,
    user_hash: user_hash,
    custom_data:{
      demo: demo
    },
    widget: {
      activator: '#IntercomDefaultWidget',
      label: 'Support',
      use_counter: true
    }
  };
}

function loadIntercom() {
  if(!window.intercomDisabled) {
    (function() {
      function async_load() {
        var s = document.createElement('script');
        s.type = 'text/javascript'; s.async = true;
        s.src = 'https://api.intercom.io/api/js/library.js';
        var x = document.getElementsByTagName('script')[0];
        x.parentNode.insertBefore(s, x);
      }

      $(async_load);
    })();
  }
}
