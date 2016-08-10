//TODO remove this file if this intro is deprecated

var addIntroToTile, initIntro;


initIntro = function(intro) {
  intro.setOptions({
    showStepNumbers: false,
    doneLabel: 'Got it',
    tooltipClass: 'user_submitted_tile_intro'
  });
  return intro.start();
};

addIntroToTile = function() {
  var intro;
  intro = "Accept the Tile to use it in your Board, " + "or Ignore it to mark it as reviewed.";
  return $(".tile_thumbnail.user_submitted").first().attr("data-intro", intro);
};

window.userSubmittedTileIntro = function(show) {
  var intro;
  if (show !== "true") {
    return;
  }
  addIntroToTile();
  intro = introJs();
  return initIntro(intro);
};
