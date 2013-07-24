// Links toggle mobile nav
if ($(document).width() < 928) {
  $('.top-bar-section .right a').click(function() {
    $('.top-bar').removeClass('expanded');
  });
}

// Animates nav upon scroll
var viewWindow = $(window)
$(viewWindow).scroll(function() {
	$('.top-bar-section a').removeClass('current_section');
	if (viewWindow.scrollTop() <= 7) {
		$('header').css('top', '7px');
	} else if (viewWindow.scrollTop() > 7) {
    $('header').css('top', '0');
  } if (viewWindow.scrollTop() >= 500 && viewWindow.scrollTop() <= 4300) {
  	$('#what_we_do').addClass('current_section');
  } else if (viewWindow.scrollTop() >= 4300 && viewWindow.scrollTop() <= 4860) {
  	$('#work_together').addClass('current_section');
  } 
});

// Animate scroll
window.HEngage = {
  scrollToElement: function(selector) {
    var topOffset = $(selector).offset().top;
    $('html, body').animate({scrollTop: topOffset-=60}, 850);
  }
};

// Scroll to sections
$('#what_we_do').click(function(event){
  event.preventDefault();
  HEngage.scrollToElement('#capture_attention');
  mpq.track("What We Do clicked");
});

$('#work_together').click(function(event){
  event.preventDefault();
  HEngage.scrollToElement('#pricing');
  mpq.track("Pricing clicked");
});