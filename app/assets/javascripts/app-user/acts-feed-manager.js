var Airbo = window.Airbo || {};

Airbo.ActsFeedManager = (function() {
  function renderActs(acts) {
    var orgId = document.getElementById("current-org-id").getAttribute("data");
    acts.forEach(function(act) {
      act.validOrg = act.points && orgId !== "1072";
      var actTemplate = HandlebarsTemplates["acts/act"](act);
      $(".js-user-acts").append(actTemplate);
    });
  }

  function bindMore() {
    $(".js-see-more-acts").on("click", function(e) {
      e.preventDefault();
      $("#see-more-spinner").show();
      $(".js-see-more-acts .button_text").hide();
      getActs(displayMoreActs);
    });
  }

  function displayMoreActs(data) {
    renderActs(data.acts);
    if (data.meta.lastPage === true) {
      $(".js-see-more-acts").hide();
    } else {
      $(".js-activity-feed-component").data("page", data.meta.nextPage);
      $(".js-see-more-acts .button_text").show();
      $("#see-more-spinner").hide();
    }
  }

  function getActs(cb) {
    var params = $(".js-activity-feed-component").data();
    $.get(params.path, params, function(data) {
      cb(data);
    });
  }

  function setInitialActs(data) {
    if (data.acts.length > 0) {
      $(".js-placeholder-act").fadeOut();
      renderActs(data.acts);
      $(".js-activity-feed-component").data("page", data.meta.nextPage);
      $(".js-user-acts").fadeIn();
      if (data.meta.lastPage !== true) $(".js-see-more-acts").show();
    } else {
      $(".js-placeholder-act").fadeOut("slow", function() {
        var exampleAct = HandlebarsTemplates["acts/exampleAct"]({
          helpers: { avatarPath: missingAvatarPath() }
        });
        $(".js-user-acts").append(exampleAct);
        $(".js-user-acts").fadeIn();
      });
    }
  }

  function missingAvatarPath() {
    return $(".js-activity-feed-component").data("missingAvatarPath");
  }

  function init() {
    var $component = $(".js-activity-feed-component");
    $component.append(HandlebarsTemplates["acts/actsFeed"]);

    var placeholderAct = HandlebarsTemplates["acts/placeholderAct"]({
      helpers: { avatarPath: missingAvatarPath() }
    });
    $component.append(placeholderAct);

    getActs(setInitialActs);
    bindMore();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".js-activity-feed-component").length > 0) {
    Airbo.ActsFeedManager.init();
  }
});
