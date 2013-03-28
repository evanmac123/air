// ========== Our ~*custom*~ slider! ===========
slideCount = 0;
$names = $("#slide_name li");
$slides = $("#slider .slide");
totalSlides = $("#slider .slide").length;
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
    id = $(this).attr('id');

    if (id == "next_slide") {slideCount++;}
    if (id == "prev_slide") {slideCount--;}
    doTheSlide();
});

$("#slide_name a").click(function (){
    slideBoxes = $("#slide_name li");
    currentSlideBox = $(this).parent();
    currentSlideName = $(this).parent().attr('id');

    slideBoxes.removeClass("current_slide");
    currentSlideBox.addClass("current_slide");
    if (currentSlideName == "sn_play") {slideCount = 0;}
    if (currentSlideName == "sn_message") {slideCount = 1;}
    if (currentSlideName == "sn_interact") {slideCount = 2;}
    if (currentSlideName == "sn_measure") {slideCount = 3;}
    doTheSlide();
});

// Center the slider names
function centerSliderNames() {
    sliderWidth = $("#slider").width();
    namesBox = $("#slide_name").width();  
    leftMargin = (sliderWidth-namesBox)/2;    
    $("#slide_name").css("marginLeft", leftMargin); 
}
$(document).ready(function() {
    centerSliderNames();
    $(window).resize(function() {centerSliderNames();});
});

// ========== Our stats slider, beepboop ===========
$('#stats_name li').hover(function(){
    allNames = $('#stats_name li');
    allStats = $('#stats_holder ul');
    allUses = $('#stats_usage li');
    namePosition = $(this).index();
    currentStat = allStats.eq(namePosition);
    currentUse = allUses.eq(namePosition);

    allNames.removeClass('current_stat_name');
    allStats.hide();
    allUses.hide();
    $(this).addClass('current_stat_name');
    currentStat.show();
    currentUse.show();
});