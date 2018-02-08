var Airbo = window.Airbo || {};

Airbo.UserTilePreview = (function() {
  var nextTileParams = {};

  function showOrHideStartOverButton(showFlag) {
    if (showFlag) {
      $("#guest_user_start_over_button").show();
    } else {
      $("#guest_user_start_over_button").hide();
    }
  }

  function transitionTile(data) {
    var $viewer = $(".viewer");

    $viewer.fadeOut("fast", function() {
      $viewer.html(data.tile_content);
      $("#tile_img_preview")
        .load(function() {
          $viewer.fadeIn("fast");
          initTile();
        })
        .error(function() {
          $viewer.fadeIn("fast");
          initTile();
        });
    });

    showOrHideStartOverButton(
      $("#slideshow .tile_holder").data("show-start-over") === true
    );
  }

  function navigationParams(target) {
    var direction = target.is("#next") ? 1 : -1;
    return { offset: direction };
  }

  function getTileByNavigation(target) {
    var params = $.extend(nextTileParams, navigationParams(target), {
      afterPosting: false
    });

    $("#tileGrayOverlay").fadeIn("slow");
    $("html").animate({ scrollTop: 0 }, "slow", function() {
      getTile(params, transitionTile);
    });
  }

  function getTileAfterAnswer(responseText) {
    var params = $.extend(nextTileParams, { offset: 1, afterPosting: true });

    var cb = function(data, status, xhr) {
      var handler = function() {
        if (Airbo.UserTilePreview.fromSearch !== true) {
          if (data.all_tiles_done === true) {
            $(".content .container.row").replaceWith(data.tile_content);
            showOrHideStartOverButton(data.show_start_over_button === true);
          } else {
            transitionTile(data);
          }
        } else {
          Airbo.UserTileSearch.closeTileViewAfterAnswer();
        }
      };
      $.when(
        Airbo.ProgressAndPrizeBar.predisplayAnimations(data, responseText)
      ).then(handler);

      Airbo.PubSub.publish("tileAnswered");
    };

    getTile(params, cb);
  }

  function getTile(params, cb) {
    var url = params.url || nextTileUrl();
    $.ajax({
      type: "GET",
      url: url,
      data: params,
      success: cb
    });
  }

  function postTileCompletionPing(target) {
    var tileHolder = $(".tile_holder");
    var tileId = tileHolder.data("current-tile-id");
    var config = tileHolder.data("config");

    var tileType;

    if ($("body").hasClass("public-board")) {
      tileType = "Public Tile";
    } else if ($(".js-multiple-choice-answer").hasClass("invitation_answer")) {
      tileType = "Spouse Invite";
    } else if (
      $(".js-multiple-choice-answer").hasClass("change_email_answer")
    ) {
      tileType = "Email Change";
    } else {
      tileType = "User";
    }

    var pingParams = {
      tile_id: tileId,
      tile_module: config.type,
      allow_free_reponse: config.allowFreeResponse,
      is_anonymous: config.isAnonymous,
      tile_type: config.signature
    };

    if (tileType == "Spouse Invite") {
      pingParams.sent_invite = target.hasClass("invitation_answer");
    }
    Airbo.Utils.ping("Tile - Completed", pingParams);
  }

  function postTileCompletion(target) {
    var response;
    var answer;
    var idx = target.data("answerIndex");
    var form = $("form#tile_completion");
    var url = form.attr("action");

    form.find("#answer_index").val(idx);

    postTileCompletionPing(target);
    response = $.ajax({
      type: "POST",
      url: url,
      data: form.serializeArray()
    });
    return response;
  }

  function initNextTileParams() {
    nextTileParams = {
      partial_only: true,
      completed_only: $("#slideshow .tile_holder").data("completed-only"),
      previous_tile_ids: $("#slideshow .tile_holder").data("current-tile-ids")
    };
  }

  function targetAnswerClicked(target) {
    $("#tileGrayOverlay").fadeIn("slow");
    $("html").animate({ scrollTop: 0 }, "slow");

    var tileCompletionPosted = postTileCompletion(target);

    $.when(tileCompletionPosted).then(function(data) {
      getTileAfterAnswer(data);
    });
  }

  //FIXME this is a shitty way to do this!!

  function rightAnswerClicked(answer) {
    var customAnswerType = function() {};
    if (answer.hasClass("invitation_answer")) {
      customAnswerType = Airbo.DependentEmailForm.get;
    } else if (answer.hasClass("change_email_answer")) {
      customAnswerType = Airbo.ChangeEmailForm.get;
    }

    $.when(customAnswerType())
      .done(function() {
        targetAnswerClicked(answer);
      })
      .fail(function() {
        Airbo.TileAnswers.reinitEvents();
      });
  }

  function nextTileUrl() {
    return "/tiles/" + $("#slideshow .tile_holder").data("current-tile-id");
  }

  function initAnonymousTooltip() {
    $(".js-anonymous-tile-tooltip").tooltipster({
      theme: "tooltipster-shadow"
    });
  }

  function initTile() {
    initNextTileParams();
    setUpAnswers();
    initAnonymousTooltip();
    Airbo.Utils.TileLinkHandler.init();
    Airbo.UserTileShareOptions.init();
  }

  function setUpAnswers() {
    Airbo.TileAnswers.init({
      onRightAnswer: rightAnswerClicked
    });
  }

  function bindTileCarouselNavigationButtons() {
    $("body").on("click", "#next, #prev", function(event) {
      event.preventDefault();
      getTileByNavigation($(event.target));
    });
  }

  function init(fromSearch) {
    this.fromSearch = fromSearch;
    bindTileCarouselNavigationButtons();
    initTile();
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".tiles-index").length > 0) {
    Airbo.UserTilePreview.init();
  }
  // external tile preview
  if ($(".tile.tile-show").length > 0) {
    Airbo.TileAnswers.init();
  }
});
