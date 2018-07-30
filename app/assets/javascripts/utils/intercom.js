var Airbo = window.Airbo || {};

// Airbo.OpenIntercom = (function() {
//   function init() {
//     if (Airbo.Utils.userIsEndUser()) {
//       bindEndUserIntercomSettings();
//     }
//
//     $(".open_intercom").on("click", function(event) {
//       event.preventDefault();
//       if (Airbo.Utils.userIsEndUser()) {
//         Intercom("boot", window._intercomSettings);
//       }
//       openIntercom();
//     });
//   }
//
//   function openIntercom() {
//     Intercom("show");
//   }
//
//   function bindEndUserIntercomSettings() {
//     // Notice the underscore: "_intercomSettings"
//     // This because if we called it intercomSettings, no underscore, it'd
//     // automatically push the user data to Intercom when we call loadIntercom,
//     // and we want to wait on that until the user actually tries to open
//     // Intercom.
//     var currentUser = Airbo.Utils.currentUser();
//     $.extend(window.intercomSettings, {
//       hide_default_launcher: true
//     });
//
//     window._intercomSettings = $.extend(
//       {},
//       window.intercomSettings,
//       Airbo.Utils.intercomUser()
//     );
//   }
//
//   return {
//     init: init
//   };
// })();
//
// $(function() {
//   if ($(".open_intercom").length > 0) {
//     Airbo.OpenIntercom.init();
//   }
// });
