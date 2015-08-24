var Airbo = window.Airbo || {};

Airbo.tilePointsSlider = (function() {
 
  function refreshPointsField(){
    //max points 20, max slider 200. so:
    points = Math.ceil($( "#points_slider" ).slider( "value" )/10);
    $("#tile_builder_form_points").val(points);
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

  function init(){
    $( "#points_slider" ).slider({
      orientation: "horizontal",
      range: "min",
      max: 200,
      min: 1,
      value: 1,
      slide: refreshPointsField,
      change: refreshPointsField
    });

    start_points = ($("#tile_builder_form_points").val() ? $("#tile_builder_form_points").val() : 10) * 10;
    $( "#points_slider" ).slider( "value", start_points );

    addPointsPopUp();
    refreshPointsField();

  }

  return {
   init: init
  }

}())
