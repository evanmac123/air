var terms = ["programs", "social recruiting", "processes", "culture", "benefits", "wellness initiative", "training"];

function rotateTerm() {
	var rotateWrapper = $(".hero .rotate");
	var wordWrapper = $(".hero .rotate .rotating_word");
  var ct = wordWrapper.data("term") || 0;
  var word = wordWrapper.data("term", ct == terms.length -1 ? 0 : ct + 1).text(terms[ct]);
  rotateWrapper.fadeIn().delay(2000).fadeOut(500, rotateTerm);
}

$(rotateTerm);