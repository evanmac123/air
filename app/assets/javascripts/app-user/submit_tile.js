var Airbo = window.Airbo || {};

var addExplainBtn,
  askUsSel,
  closeBtn,
  explainBtnClass,
  infoIcon,
  modal,
  suggestLink,
  tooltip,
  tooltipClass;

tooltipClass = function() {
  return "submit_tile_intro";
};

tooltip = function() {
  return $("." + tooltipClass());
};

explainBtnClass = function() {
  return "intojs-explainbutton";
};

addExplainBtn = function() {
  return tooltip()
    .find(".introjs-tooltipbuttons")
    .append("<a class='" + explainBtnClass() + "'>How it works</a>");
};

window.submitTileIntro = function() {
  var intro;
  intro = introJs();
  intro.setOptions({
    showStepNumbers: false,
    skipLabel: "Got it",
    tooltipClass: tooltipClass()
  });
  $(window).on("load", function() {
    intro.start();
    return addExplainBtn();
  });
  return $(document).on("click", "." + explainBtnClass(), function(e) {
    e.preventDefault();
    intro.exit();
    return modal().foundation("reveal", "open", {
      animation: "fade",
      closeOnBackgroundClick: true
    });
  });
};

modal = function() {
  return $("#submit_tile_modal");
};

closeBtn = function() {
  return modal().find(".close");
};

askUsSel = function() {
  return "#ask_us";
};

suggestLink = function() {
  return $(".suggest_tile_redirect");
};

infoIcon = function() {
  return $("#creation .help");
};

window.submitTileModal = function() {
  closeBtn().click(function(e) {
    e.preventDefault();
    return modal().foundation("reveal", "close");
  });
  return infoIcon().click(function(e) {
    e.preventDefault();
    return modal().foundation("reveal", "open", {
      animation: "fade",
      closeOnBackgroundClick: true
    });
  });
};
