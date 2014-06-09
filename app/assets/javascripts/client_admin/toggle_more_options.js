$(document).ready(function() {
  var more = "More options";
  var less = "Less options";
  var i = 1;

  $('a#more-options').click(function(event) {
    $('.extra-user-info').fadeToggle();
    i++;
    if (i%2 != 0) {
      $(this).html(more);
    }else {
      $(this).html(less);
    }

    event.preventDefault();
  });
})
