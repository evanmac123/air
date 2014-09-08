/*
fast fade slides
*/
var marketingSlider = function(){
  (function($){
    var cont = $('#slides');
    cont.find('li').css('position', 'absolute').hide().filter('.active').fadeIn('slow');
    cont.height(cont.find('.active').outerHeight());
    
    var slides = $('#slides').find('li').length;
    var now = 1;

    var prev = function(){
      if(now > 1){
          cont.find('.active').fadeOut('slow').removeClass('active').prev().addClass('active').fadeIn('slow');
          $('#slideBtns').find('.active').removeClass('active').prev().addClass('active');
        now--;
      }
    };
    
    var next = function(){
      if(now < slides){
          cont.find('.active').fadeOut('slow').removeClass('active').next().addClass('active').fadeIn('slow');
          $('#slideBtns').find('.active').removeClass('active').next().addClass('active');
        now++;
      }
    };
    
    $('#prevBtn').click(function(){
      prev();
      return false;
    });

    $('#nextBtn').click(function(){
      next();
      return false;
    });

    $p = 0;
    var $prev = function (c) {
      if ($(c).prev().length) {
          $p++;
          $prev($(c).prev());
      } else {
          now = $p + 1;
          $p = 0;
      }
    };

    var changeCircles = function(){
      $('#slideBtns li').each(function() {
        content = $(this).hasClass("active") ? "fa-circle" : "fa-circle-o";
        $( this ).find("a").html("<i class='fa " + content + "'></i>");
      });
    }

    $('#slideBtns').find('a').click(function(){
      $a = $(this);
      if(!$a.parent('li').hasClass('active')){
        $href = $a.attr('href');
        $('#slides').find('.active').fadeOut('slow').removeClass('active');
        $($href).fadeIn('slow').addClass('active');
        $('#slideBtns').find('.active').removeClass('active');
        $a.parent('li').addClass('active');
        $('#slides').height($($href).outerHeight());
        $prev($('#slideBtns').find('.active'));
      }
      changeCircles();
      return false;
    });

    changeCircles();
  })(jQuery);
}