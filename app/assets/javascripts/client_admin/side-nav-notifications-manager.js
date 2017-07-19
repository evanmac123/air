var Airbo = window.Airbo || {};
Airbo.ClientAdmin = Airbo.ClientAdmin || {};


Airbo.ClientAdmin.SideNavNotificationsManager = (function(){
  var greenClass = "success";
  var yellowClass = "warning";
  var redClass = "alert";
  var notificationClasses = [greenClass, yellowClass, redClass].join(" ");

  function numberDependentNotificationClass(number, bounds) {
    if (number < bounds.lower) {
      return greenClass;
    } else if (bounds.middle && number < bounds.middle) {
      return yellowClass;
    } else {
      return redClass;
    }
  }

  function setNotification($notification, content, notificationClass) {
    $notification.data("notificationContent", content);
    $notification.html(content);
    updateNotificationClass($notification, notificationClass);
  }

  function initShareTabNotification() {
    Airbo.PubSub.subscribe("updateShareTabNotification", updateShareTab);

    var sharableTilesCount = $(".js-notification-share_tiles").data("notificationContent");

    Airbo.PubSub.publish("updateShareTabNotification", { number: sharableTilesCount });
  }

  function updateShareTab(event, options) {
    var $shareTabNotification = $(".js-notification-share_tiles");
    var notificationClass = numberDependentNotificationClass(options.number, {
      lower: 6,
      middle: 9
    });

    setNotification($shareTabNotification, options.number, notificationClass);
  }

  function updateNotificationClass($notification, notificationClass) {
    $notification.removeClass(notificationClasses);
    $notification.addClass(notificationClass);
  }

  function initReportsTabNotification() {
    var $reportsTabNotification = $(".js-notification-board_activity");
    var content = $reportsTabNotification.data("notificationContent");

    setNotification($reportsTabNotification, content, greenClass);
  }

  function init() {
    initShareTabNotification();
    initReportsTabNotification();
    $(".js-sidenav-badge").removeClass("hidden");
  }

  return {
    init: init
  };

}());

$(function(){
  if (Airbo.Utils.nodePresent(".js-client-admin-side-nav")) {
    Airbo.ClientAdmin.SideNavNotificationsManager.init();
  }
});
