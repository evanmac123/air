var animateCounter = function(domID, previous, current, duration, callback) {
  var counter = new countUp(domID, previous, current, 0, duration);
  counter.useEasing = false;

  var element = $('#' + domID);
  element.addClass('counting');
  counter.start(function() {
    element.removeClass('counting');
    if(typeof(callback) === 'function') {
      callback();
    }
  });
};

var progressBar = function() {return $('#completed_progress')};

var fillBarToFinalPercentage = function(finalPercentage, allTilesDone, callback) {
  progressBar().addClass('counting');
  return progressBar().animate({width: finalPercentage}, 750, 'linear', function() {
    progressBar().removeClass('counting');
    if(typeof(callback) === 'function') {
      callback();
    } 
  });
};

var loadFollowingTile = function() {
  loadNextTileWithOffset(1);
}

var fillBarEntirely = function(previousTickets, currentTickets, finalPercentage, allTilesDone) {
  var deferred = $.Deferred();

  var emptyBarCallback = function() {
    progressBar().css('width', '0%');
    fillBarToFinalPercentage(finalPercentage, allTilesDone, function() {
      animateCounter('user_tickets', previousTickets, currentTickets, 0.1, deferred.resolve);
    });
  }

  progressBar().addClass('counting');
  progressBar().animate({width: '100%'}, 750, 'linear', emptyBarCallback);
  return deferred.promise();
};

var fillBar = function(previousTickets, currentTickets, finalPercentage, allTilesDone) {
  var ticketsIncreased = (previousTickets < currentTickets);
  if(ticketsIncreased) {
    return(fillBarEntirely(previousTickets, currentTickets, finalPercentage, allTilesDone));
  } else {
    return(fillBarToFinalPercentage(finalPercentage, allTilesDone)); 
  }
}

var scrollToTop = function() { $.Deferred(window.scrollTo(0,0)).promise(); }

var pointCounter = function() {
  var originalPoints = parseInt($('#tile_point_value').text());
  return(new countUp('tile_point_value', originalPoints, 0, 0, 1.0));
}

var highlightEarnablePoints = function() {
  $('.earnable_points').css('background', '#4FAA60').css('box-shadow', 'none');
}

var tileCompletedPreloadAnimations = function() {
  highlightEarnablePoints();

  var callbacksDoneDeferred = $.Deferred();

  pointCounter().start(function() {
    $.when(grayoutTile()).
      then(scrollToTop).
      then(function(){callbacksDoneDeferred.resolve()})
  });

  return callbacksDoneDeferred.promise();
}

var markCompletedRightAnswer = function(event) {
  $(event.target).addClass('clicked_right_answer');
}

var predisplayAnimations = function(tileData, tilePosting) {
  $.when(tilePosting).then(function() {
    var startingData = $.parseJSON(tilePosting.responseText);
    $('#js-flashes').html(tileData.flash_content);
    $('#user_points').html(tileData.delimited_starting_points);
    $('#progress_bar .small_cap').html(tileData.master_bar_point_content);
    $('#user_tickets').html(tileData.starting_tickets);

    return $.when(animateCounter('user_points', startingData.starting_points, tileData.ending_points, 0.5)).then(function() {
      return fillBar(startingData.starting_tickets, tileData.ending_tickets, tileData.master_bar_ending_percentage, tileData.all_tiles_done);
    });
  })
}
