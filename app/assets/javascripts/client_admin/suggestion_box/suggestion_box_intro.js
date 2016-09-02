var accessModal, addExplainBtn, closeBtn, explainBtnClass, helpBtn, initIntro, modal, pickUsersBtn, title, titleSel, tooltip, tooltipClass;

titleSel = function() {
  return "#suggestion_box_title";
};

title = function() {
  return $(titleSel());
};

tooltipClass = function() {
  return "suggestion_box_intro";
};

tooltip = function() {
  return $("." + tooltipClass());
};

explainBtnClass = function() {
  return 'intojs-explainbutton';
};

addExplainBtn = function() {
  return tooltip().find(".introjs-tooltipbuttons").append("<a class='" + (explainBtnClass()) + "'>How it works</a>");
};

initIntro = function(intro) {
  if (title().attr("data-intro")) {
    intro.setOptions({
      showStepNumbers: false,
      doneLabel: 'Got it',
      tooltipClass: tooltipClass()
    });
    intro.start();
    return addExplainBtn();
  }
};

window.suggestionBoxIntro = function() {
  var intro;
  intro = introJs();
  initIntro(intro);
  return $(document).on("click", "." + explainBtnClass(), function(e) {
    e.preventDefault();
    intro.exit();
    return modal().foundation('reveal', 'open');
  });
};

modal = function() {
  return $("#suggestion_box_help_modal");
};

closeBtn = function() {
  return modal().find(".close, .close-reveal-modal");
};

pickUsersBtn = function() {
  return modal().find(".submit");
};

accessModal = function() {
  return $('#suggestions_access_modal');
};

helpBtn = function() {
  return $("#suggestion_box_sub_menu .help");
};

window.suggestionBoxHelpModal = function() {
  helpBtn().click(function(e) {
    e.preventDefault();
    modal().foundation('reveal', 'open');
  });

  closeBtn().click(function(e) {
    e.preventDefault();
    modal().foundation('reveal', 'close');
  });

  return pickUsersBtn().click(function(e) {
    e.preventDefault();
    accessModal().foundation('reveal', 'open');
  });
};
