$(function() {
  // Anything in here gets called onload
  $('.close_tutorial').click(function(){
    closeTutorial();
  });
  $('#gear').click(function(){
    showMenu();
  });
});


  //This function removes overlay to free the UI
function spotlightOff() {
 $('.overlaying').animate({
        opacity: 0
    }, 100, function () {
        $('.overlaying').removeClass('overlay');
    });
}

//This function adds an overlay on the UI and add a
//white background to the html element id passed as an argument in the func
function spotlightOn(element) {
    $(element).addClass('spotlight');
    $(element).css(" background-color", "white");
    $('.overlaying').addClass('overlay');
}

function displayToolTip(trigger, display, x, y, reference){
  var highlighted = $(trigger);
  var wall_tooltip = highlighted.tooltip({ // binding the tooltip to the html element with id = wall
          tip: display,
          fadeOutSpeed: 100,
          predelay: 400,
          delay: 100000000,
          offset: [y, x],
          position: reference,
          api: true
      });

      wall_tooltip.show();//then show the first tool tip when document is ready
      spotlightOn(highlighted);
}

function hideToolTip(){
  $('#black_tooltip').toggle();
}
function closeTutorial(){
  spotlightOff();
  hideToolTip();
  var options = { _method : "put", tutorial_request : "close" };
  $.post('tutorial', options);
}


function showMenu(){
  var gear = $('#gear');
  var options = $('#options');
  options.show();
  gear.hide();
  $('#tutorial_menu').mouseleave(function(){
    options.hide();
    gear.show();
  });
}
    