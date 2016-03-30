var Airbo = window.Airbo || {};
Airbo.SingleTilePreview =(function(){

function checkInTile() {
  return $(".tile_multiple_choice_answer").length === 1;
};

function isOnExplorePage() {
  return window.location.href.match(/explore/) !== null;
};

function isOnClientAdminPage() {
  return window.location.href.match(/client_admin/) !== null;
};

 function getURLParameter(sParam) {
  var i, j, ref, sPageURL, sParameterName, sURLVariables;
  sPageURL = window.location.search.substring(1);
  sURLVariables = sPageURL.split('&');
  for (i = j = 0, ref = sURLVariables.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    sParameterName = sURLVariables[i].split('=');
    if (sParameterName[0] === sParam) {
      return sParameterName[1];
    }
  }
};

 function grayoutTile() {
  return $('#spinner_large').fadeIn('slow');
};

 function ungrayoutTile() {
  return $('#spinner_large').fadeOut('slow');
};

 function showOrHideStartOverButton(showFlag) {
  if (showFlag) {
    return $('#guest_user_start_over_button').show();
  } else {
    return $('#guest_user_start_over_button').hide();
  }
};

 function updateNavbarURL(newTileId) {
  var newURL, tag;
  newURL = newTileId.toString();
  tag = getURLParameter('tag');
  if (tag != null) {
    newURL += "?tag=" + tag;
  }
  return History.pushState(null, null, newURL);
};

 function loadNextTileWithOffset(offset, preloadAnimations, predisplayAnimations, tilePosting) {
  var afterPosting, url;
  afterPosting = typeof tilePosting !== 'undefined';
  if (preloadAnimations == null) {
    preloadAnimations = $.Deferred().resolve();
  }
  if (tilePosting == null) {
    tilePosting = $.Deferred().resolve();
  }
  if (predisplayAnimations == null) {
    predisplayAnimations = function() {
      return $.Deferred().resolve();
    };
  }
  url = '/tiles/' + $('#slideshow .tile_holder').data('current-tile-id');
  return $.when(preloadAnimations, tilePosting).then(function() {
    return $.get(url, {
      partial_only: true,
      offset: offset,
      after_posting: afterPosting,
      completed_only: $('#slideshow .tile_holder').data('completed-only'),
      previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')
    }, function(data) {
      return $.when(predisplayAnimations(data, tilePosting)).then(function() {
        if (data.all_tiles_done === true && afterPosting) {
          $('.content .container.row').replaceWith(data.tile_content);
          showOrHideStartOverButton(data.show_start_over_button === true);
        } else {
          $('#slideshow').html(data.tile_content);
          setUpAnswers();
          showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
          ungrayoutTile();
        }
        if (data.show_conversion_form === true) {
          if ($("body").data("public-board") === true) {
            Airbo.ScheduleDemoModal.openModal();
            return Airbo.ScheduleDemoModal.modalPing("Source", "Auto");
          } else {
            return lightboxConversionForm();
          }
        }
      });
    });
  });
};

 function loadNextTileWithOffsetForExplorePreview(offset) {
  var url;
  url = '/explore/tile/' + $('#tile_preview_section .tile_holder[data-current-tile-id]').data('current-tile-id');
  return $.get(url, {
    partial_only: true,
    offset: offset,
    tag: getURLParameter("tag")
  }, function(data) {
    $('#tile_preview_section').html(data.tile_content);
    updateNavbarURL(data.tile_id);
    $('#spinner_large').css("display", "block");
    setUpAnswersForPreview();
    return ungrayoutTile();
  });
};

 function loadNextTileWithOffsetForManagePreview(offset) {
  var url;
  url = '/client_admin/tiles/' + $('[data-current-tile-id]').data('current-tile-id');
  return $.get(url, {
    partial_only: true,
    offset: offset
  }, function(data) {
    $('.content').children(".row").replaceWith($(data.tile_content));
    updateNavbarURL(data.tile_id);
    $('#spinner_large').css("display", "block");
    window.sharableTileLink();
    window.bindTagNameSearchAutocomplete('#add-tag', '#tag-autocomplete-target', "/client_admin/tile_tags");
    setUpAnswersForPreview();
    return ungrayoutTile();
  });
};

 function attachWrongAnswer(answerLink, target) {
  return answerLink.click(function(event) {
    event.preventDefault();
    target.html("Sorry, that's not it. Try again!");
    target.slideDown(250);
    return $(this).addClass("clicked_wrong");
  });
};

 function nerfNerfedAnswers() {
  return $('.nerfed_answer').click(function(event) {
    return event.preventDefault();
  });
};

 function disableAllAnswers() {
  return $(".right_multiple_choice_answer").removeAttr("href").unbind();
};

 function findCsrfToken() {
  return $('meta[name="csrf-token"]').attr('content');
};

 function postTileCompletion(event) {
  var link;
  link = $(event.target);
  return $.ajax({
    type: "POST",
    url: link.attr('href'),
    headers: {
      'X-CSRF-Token': findCsrfToken()
    }
  });
};

 function pingRightAnswerInPreview(tileId) {
  return $.post("/ping", {
    event: 'Explore page - Interaction',
    properties: {
      action: 'Clicked Answer',
      tile_id: tileId
    }
  });
};

 function rightAnswerClicked(event) {
  var posting, preloadAnimationsDone;
  posting = postTileCompletion(event);
  markCompletedRightAnswer(event);
  preloadAnimationsDone = tileCompletedPreloadAnimations(event);
  return loadNextTileWithOffset(1, preloadAnimationsDone, predisplayAnimations, posting);
};

 function markCompletedRightAnswer(event) {
  return $(event.target).addClass('clicked_right_answer');
};

 function attachRightAnswerMessage(event) {
  if (!checkInTile()) {
    return $(event.target).siblings('.answer_target').html("Correct!").slideDown(250);
  }
};

 function rightAnswerClickedForPreview(event) {
  markCompletedRightAnswer(event);
  return attachRightAnswerMessage(event);
};

 function attachRightAnswers() {
  return $('.right_multiple_choice_answer').one("click", function(event) {
    event.preventDefault();
    return rightAnswerClicked(event);
  });
};


 function attachRightAnswersForPreview() {
  return $('.right_multiple_choice_answer').one("click", function(event) {
    event.preventDefault();
    rightAnswerClickedForPreview(event);
    disableAllAnswers();
    if (isOnExplorePage()) {
      pingRightAnswerInPreview($(event.target).data('tile-id'));
      if (!window.guestForTilePreview) {
        grayoutTile();
        return loadNextTileWithOffsetForExplorePreview(1);
      }
    }
  });
};

 function attachWrongAnswers() {
  return _.each($('.wrong_multiple_choice_answer'), function(wrongAnswerLink) {
    var target;
    wrongAnswerLink = $(wrongAnswerLink);
    target = wrongAnswerLink.siblings('.answer_target');
    return attachWrongAnswer(wrongAnswerLink, target);
  });
};

 function setUpAnswers() {
  nerfNerfedAnswers();
  attachRightAnswers();
  return attachWrongAnswers();
};

 function setUpAnswersForPreview() {
  attachRightAnswersForPreview();
  return attachWrongAnswers();
};


bindTileCarouselNavigationButtons = function() {
  return $(function() {
    $("body").on('click', '#next', function(event) {
      event.preventDefault();
      grayoutTile();
      if (isOnExplorePage()) {
        return loadNextTileWithOffsetForExplorePreview(1);
      } else if (isOnClientAdminPage()) {
        return loadNextTileWithOffsetForManagePreview(1);
      } else {
        return loadNextTileWithOffset(1);
      }
    });
    return $("body").on('click', '#prev', function(event) {
      event.preventDefault();
      grayoutTile();
      if (isOnExplorePage()) {
        return loadNextTileWithOffsetForExplorePreview(-1);
      } else if (isOnClientAdminPage()) {
        return loadNextTileWithOffsetForManagePreview(-1);
      } else {
        return loadNextTileWithOffset(-1);
      }
    });
  });
};



  function init(){
    setUpAnswers();
  }
  return {
   init: init
  }

}());


var attachRightAnswerMessage, attachRightAnswers, attachRightAnswersForPreview, attachWrongAnswer, attachWrongAnswers, checkInTile, disableAllAnswers, findCsrfToken, getURLParameter, grayoutTile, isOnClientAdminPage, isOnExplorePage, loadNextTileWithOffset, loadNextTileWithOffsetForExplorePreview, loadNextTileWithOffsetForManagePreview, markCompletedRightAnswer, nerfNerfedAnswers, pingRightAnswerInPreview, postTileCompletion, rightAnswerClicked, rightAnswerClickedForPreview, setUpAnswers, setUpAnswersForPreview, showOrHideStartOverButton, ungrayoutTile, updateNavbarURL;

window.loadNextTileWithOffset = loadNextTileWithOffset;

window.setUpAnswers = setUpAnswers;

window.setUpAnswersForPreview = setUpAnswersForPreview;

window.grayoutTile = grayoutTile;

window.ungrayoutTile = ungrayoutTile;

window.

