var Airbo = window.Airbo || {};

Airbo.TileStatsMessageSender = (function(){
  function initEvents() {
    initSendMessage();
    initSendTestMessage();
  }

  function initSendMessage() {
    $(".js-send-tile-targeted-message").one("click", function(e) {
      e.preventDefault();
      sendMessage();
    });
  }

  function initSendTestMessage() {
    $(".js-send-tile-targeted-test-message").one("click", function(e) {
      e.preventDefault();
      sendTestMessage();
    });
  }

  function sendMessage() {
    $.ajax({
      url: tileUserNotificationPath(),
      data: tileUserNotificationParams(),
      type: "POST",
      dataType: "json",
      success: function(data, status) {
        messageSentSuccess(data);
      },
      error: function(xhr, status, error) {
        messageSentFail(xhr, status, error);
      }
    });
  }

  function sendTestMessage() {
    $.ajax({
      url: tileUserNotificationPath(),
      data: $.extend(tileUserNotificationParams(), { test_notification: true }),
      type: "POST",
      dataType: "json",
      success: testMessageSentSuccess,
      error: function(xhr, status, error) {
        messageSentFail(xhr, status, error);
      }
    });
  }

  function messageSentSuccess(data) {
    Airbo.SubComponentFlash.insert($(".tile-stats-card-content"), "Your message has been delivered.", "success");
    Airbo.TileStatsPings.ping({ action: "Tile Targeted Message Sent" });

    addNewMessageToSentTable(data);
    clearPreviousMessage();
    initSendMessage();
  }

  function addNewMessageToSentTable(data) {
    template = HandlebarsTemplates["client-admin/tile-stats-modal/tile-user-notification-row"]({notification: data.tile_user_notification});

    $(".messages-sent-table-body").prepend(template);
    $(".messages-sent-table").show();
    $(".messages-sent-empty").hide();
  }

  function testMessageSentSuccess() {
    Airbo.SubComponentFlash.insert($(".tile-stats-card-content"), "A test message has been sent to your email address.", "success");
    Airbo.TileStatsPings.ping({ action: "Test Tile Targeted Message Sent" });

    initSendTestMessage();
  }

  function messageSentFail(xhr, status, error) {
    var flashMessage = xhr.getResponseHeader("X-Message");
    var flashType = xhr.getResponseHeader("X-Message-Type");

    Airbo.SubComponentFlash.insert($(".tile-stats-card-content"), flashMessage, flashType);

    initSendTestMessage();
  }

  function clearPreviousMessage() {
    $(Airbo.TileStatsMessageEditor.editor().root).html("");
    $(".js-tile-targeted-message-subject").val("");
  }

  function tileUserNotificationParams() {
    return { tile_user_notification: {
      tile_id: $(".tile-stats-modal").data("tileStatsData").id,
      subject: currentMessageSubject(),
      message: currentMessageHTML(),
      scope_cd: currentMessageScope(),
      answer_idx: currentMessageAnswerIdx(),
    } };
  }

  function currentMessageSubject() {
    return $(".js-tile-targeted-message-subject").val();
  }

  function currentMessageHTML() {
    return Airbo.TileStatsMessageEditor.message();
  }

  function currentMessageScope() {
    return $(".js-tile-targeted-message-scope-cd .selected").data("value");
  }

  function currentMessageAnswerIdx() {
    return $(".js-tile-targeted-message-answer-idx .selected").data("value");
  }

  function tileUserNotificationPath() {
    return "/client_admin/tile_user_notifications";
  }

  function getRecipientCount() {
    $(".js-recipient-count").html('<i class="load-wheel fa fa-spin fa-spinner"> </i> people');

    $.ajax({
      url: "/client_admin/tile_user_notifications/new",
      data: tileUserNotificationParams(),
      type: "GET",
      dataType: "json",
      success: function(data, status) {
        setRecipientCount(data, status);
      }
    });
  }

  function setRecipientCount(data, status) {
    var recipientCount = data.tile_user_notification.recipient_count;

    $(".js-recipient-count").html(Handlebars.helpers.numAddCommas(recipientCount) + " " + Handlebars.helpers.pluralize(recipientCount, "person", "people"));
  }

  function init() {
    initEvents();
  }

  return {
    init: init,
    getRecipientCount: getRecipientCount
  };
}());
