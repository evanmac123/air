$(function() {
  // Anything in here gets called onload

  $('.no_thanks_tutorial').live('click', function(){
    noThanksTutorial();
  });

  $('.close_tutorial').live('click', function(){
    closeTutorial();
  });
  
  $('#finish_tutorial_button').live('click', function(){
    finishTutorial();
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
    $('.overlay').fadeIn(2000);
}

function displayToolTip(trigger, display, x, y, reference){
  var highlighted = $(trigger);
  var wall_tooltip = highlighted.tooltip({ // binding the tooltip to the html element with id = wall
          tip: display,
          effect: 'fade',
          fadeInSpeed: 1000,
          fadeOutSpeed: 100,
          predelay: 400,
          delay: 100000000,
          offset: [y, x],
          position: reference,
          api: true
  });

  setTimeout(function(){
    wall_tooltip.show() 
  }, 1500);//then show the first tool tip when document is ready
  spotlightOn(highlighted);
}

function hideToolTip(){
  $('#black_tooltip').toggle();
}

function noThanksTutorial(){
  $.fancybox.close();
  var options = { _method : "put", tutorial_request : "no_thanks" };
  $.post('tutorial', options);
}

function closeTutorial(){
  spotlightOff();
  hideToolTip();
  var options = { _method : "put", tutorial_request : "close" };
  $.post('tutorial', options);
}

function finishTutorial(){
  spotlightOff();
  hideToolTip();
  var options = { _method : "put", tutorial_request : "finish" };
  $.post('/tutorial', options);
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
    