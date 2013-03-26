if(location.search)
    alert(location.search);

$('.type_tile img').live('click', function(){
    if(!$(this).prev('input[type="checkbox"]').prop('checked')){
        $(this).prev('input[type="checkbox"]').prop('checked', true).attr('checked','checked');
        this.style.border = '5px solid #4FAA60';
        this.style.margin = '0px';
    }else{
        $(this).prev('input[type="checkbox"]').prop('checked', false).removeAttr('checked');
        this.style.border = '0';
        this.style.margin = '5px';
    }
});

// Our ~*custom*~ slider!
var slideCount = 0;
var $names = $("#slide_name li");
var $slides = $("#slider .slide");
var totalSlides = $("#slider .slide").length;
function doTheSlide() {
    $slides.fadeOut();
    $names.removeClass("current_slide");
    if (slideCount == totalSlides) {
        slideCount = 0;
        $slides.eq(slideCount).fadeIn();
        $names.eq(slideCount).addClass("current_slide");
    }
    if (slideCount <= -5) {
        slideCount = 3;
        $slides.eq(slideCount).fadeIn();
        $names.eq(slideCount).addClass("current_slide");
    }
    else {
        $slides.eq(slideCount).fadeIn();
        $names.eq(slideCount).addClass("current_slide");
    } 
}

$("#slide_buttons a").click(function(){
    var id = $(this).attr('id');

    if (id == "next_slide") {slideCount++;}
    if (id == "prev_slide") {slideCount--;}
    doTheSlide();
});

$("#slide_name a").click(function (){
    var slideBoxes = $("#slide_name li");
    var currentSlideBox = $(this).parent();
    var currentSlideName = $(this).parent().attr('id');

    slideBoxes.removeClass("current_slide");
    currentSlideBox.addClass("current_slide");
    if (currentSlideName == "sn_play") {slideCount = 0;}
    if (currentSlideName == "sn_message") {slideCount = 1;}
    if (currentSlideName == "sn_interact") {slideCount = 2;}
    if (currentSlideName == "sn_measure") {slideCount = 3;}
    doTheSlide();
});