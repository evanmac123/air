var Airbo = window.Airbo || {};

Airbo.tilePointsSlider = (function() {
  var pointsSlider
    , formPoints
    , pointSliderSelector =  "#points_slider"
    , formPointsSelector = "#tile_builder_form_points"

  function refreshPointsField(){
    //max points 20, max slider 200. so:
    var points = Math.ceil($( "#points_slider" ).slider( "value" )/10);
    formPoints.val(points);
    $(".points_num").text(points);
  }

  function addPointsPopUp(){
    $(".ui-slider-range-min").append(
      [ '<div class="points_pop_up">',
        '<span class="tooltip tip-top">',
        '<div class="points_num"></div>',
        '<div class="points_text">POINTS</div>',
        '<span class="points_nub"></span>',
        '</span>',
        '</div>'].join('') );
  }

  function initjQueryObjects(){
    formPoints = $(formPointsSelector);
    pointsSlider =$("#points_slider");
  }

  function init(){
    initjQueryObjects();

    $(pointSliderSelector ).slider({
      orientation: "horizontal",
      range: "min",
      max: 200,
      min: 1,
      value: 1,
      slide: refreshPointsField,
      change: refreshPointsField
    });

    var startPoints = (formPoints.val() ? formPoints.val() : 10) * 10;
    $( "#points_slider" ).slider( "value", startPoints );

    addPointsPopUp();
    refreshPointsField();

  }

  return {
   init: init
  }

}())
