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
  function showOrHideStartOverButton(showFlag) {
    if (showFlag) {
      $('#guest_user_start_over_button').show();
    } else {
      $('#guest_user_start_over_button').hide();
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
    $.when(preloadAnimations, tilePosting).then(function() {
      $.get(url, {
        partial_only: true,
        offset: offset,
        after_posting: afterPosting,
        completed_only: $('#slideshow .tile_holder').data('completed-only'),
        previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')
      }, function(data) {
        $.when(predisplayAnimations(data, tilePosting)).then(function() {
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
              Airbo.ScheduleDemoModal.modalPing("Source", "Auto");
            } else {
              lightboxConversionForm();
            }
          }
        });
      });
    });
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

  function rightAnswerClicked(event) {
    var posting, preloadAnimationsDone;
    posting = postTileCompletion(event);
    preloadAnimationsDone = tileCompletedPreloadAnimations(event);
    loadNextTileWithOffset(1, preloadAnimationsDone, predisplayAnimations, posting);
  };

  function setUpAnswers() {
    Airbo.TileAnswers.init({
      onRightAnswer: rightAnswerClicked
    });
  };

  function bindTileCarouselNavigationButtons() {
    $(function() {
      $("body").on('click', '#next', function(event) {
        event.preventDefault();
        grayoutTile();
        loadNextTileWithOffset(1);
      });
      $("body").on('click', '#prev', function(event) {
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
