// Links toggle mobile nav
if ($(document).width() < 928) {
  $('.top-bar-section .right a').click(function() {
    $('.top-bar').removeClass('expanded');
  });
}

// Animates nav upon scroll
var viewWindow = $(window)
$(viewWindow).scroll(function() {
	if (viewWindow.scrollTop() <= 7) {
		$('header').css('top', '7px');
	} else if (viewWindow.scrollTop() > 7) {
    $('header').css('top', '0');
  } 
});

// Animate scroll
window.HEngage = {
  scrollToElement: function(selector) {
    var topOffset = $(selector).offset().top;
    $('html, body').animate({scrollTop: topOffset-=55}, 850);
  }
};