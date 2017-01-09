var animateSectionSliding, compressSection, compressSectionHeight, compressSectionMargin, compressedSectionClass, expandSection, iOSdevice, makeVisibleAllDraftTilesButHideThem, moveBottomBoundOfSection, scrollUp, section, sectionIsCompressed, selectedBlockName, setCompressedSectionClass;

section = function() {
  return $("#draft_tiles");
};

selectedBlockName = function() {
  if ($("#draft_tiles.draft_selected").length > 0) {
    return 'draft';
  } else {
    return 'suggestion_box';
  }
};

compressSection = function(animate) {
  if (animate == null) {
    animate = false;
  }
  if (animate) {
    scrollUp(-compressSectionMargin());
    return animateSectionSliding(-compressSectionMargin(), 0, "up");
  } else {
    setCompressedSectionClass("add");
    return $(".all_draft").text("Show all");
  }
};

window.compressSection = compressSection;

compressSectionMargin = function() {
  var cutHeight, initialHeight;
  initialHeight = section().outerHeight();
  return cutHeight = compressSectionHeight() - initialHeight;
};

compressSectionHeight = function() {
  return 330;
};

moveBottomBoundOfSection = function(height) {
  return section().css("margin-bottom", height);
};

makeVisibleAllDraftTilesButHideThem = function() {
  setCompressedSectionClass("remove");
  return moveBottomBoundOfSection(compressSectionMargin() + "px");
};

expandSection = function() {
  var startProgress;
  makeVisibleAllDraftTilesButHideThem();
  startProgress = parseInt(section().css("margin-bottom"));
  return animateSectionSliding(-startProgress, startProgress, "down");
};

animateSectionSliding = function(stepsNum, startProgress, direction) {
  if (direction == null) {
    direction = "down";
  }
  section().addClass("counting");
  return $({
    progressCount: 0
  }).animate({
    progressCount: stepsNum
  }, {
    duration: stepsNum,
    easing: 'linear',
    step: function(progressCount) {
      var progressNew;
      progressNew = direction === "down" ? startProgress + parseInt(progressCount) : startProgress - parseInt(progressCount);
      return moveBottomBoundOfSection(progressNew + "px");
    },
    complete: function() {
      section().removeClass("counting");
      moveBottomBoundOfSection("");
      if (direction === "down") {
        return setCompressedSectionClass("remove");
      } else {
        return setCompressedSectionClass("add");
      }
    }
  });
};

scrollUp = function(duration) {
  if (!iOSdevice()) {
    return $('html, body').scrollTo(section(), {
      duration: duration
    });
  }
};

iOSdevice = function() {
  return navigator.userAgent.match(/(iPad|iPhone|iPod)/g);
};

setCompressedSectionClass = function(action) {
  if (action == null) {
    action = "remove";
  }
  if (action === "remove") {
    section().removeClass(compressedSectionClass());
  } else {
    section().addClass(compressedSectionClass());
  }
  Airbo.TileDragDropSort.updateTileVisibilityIn(selectedBlockName());
};

sectionIsCompressed = function() {
  return section().hasClass(compressedSectionClass());
};

compressedSectionClass = function() {
  return "compressed_section";
};

window.expandDraftSectionOrSuggestionBox = function() {
  compressSection();
  return $(".all_draft").click(function(e) {
    e.preventDefault();
    if (sectionIsCompressed()) {
      expandSection();
      return $(this).text("Minimize");
    } else {
      compressSection(true);
      return $(this).text("Show all");
    }
  });
};
