//FIXME
/*
 * Note  these functions are called from point_and_ticket_animation.js as globals
 * so we need to keep them global for now
*/

 function grayoutTile() {
  return $('#spinner_large').fadeIn('slow');
};

 function ungrayoutTile() {
  return $('#spinner_large').fadeOut('slow');
};

var Airbo = window.Airbo || {};

Airbo.UserTilePreview =(function(){

  function checkInTile() {
    return $(".tile_multiple_choice_answer").length === 1;
  };

  function showOrHideStartOverButton(showFlag) {
    if (showFlag) {
      return $('#guest_user_start_over_button').show();
    } else {
      return $('#guest_user_start_over_button').hide();
    }
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

  function attachRightAnswers() {
    return $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      return rightAnswerClicked(event);
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
    attachWrongAnswers();
  };

  function bindTileCarouselNavigationButtons() {
    return $(function() {
      $("body").on('click', '#next', function(event) {
        event.preventDefault();
        grayoutTile();
        loadNextTileWithOffset(1);
      });
      return $("body").on('click', '#prev', function(event) {
        event.preventDefault();
        grayoutTile();
        loadNextTileWithOffset(-1);
      });
    });
  };


  function init(){
    bindTileCarouselNavigationButtons();
    setUpAnswers();
  }
  return {
   init: init
  }

}());

$(document).ready(function() {
  if( $(".tiles-index").length > 0) {
    Airbo.UserTilePreview.init();
  }
});
