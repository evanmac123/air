var Airbo = window.Airbo || {}

Airbo.DraftSectionExpander = (function(){

  function section() {
    return $("#draft_tiles");
  }

  function selectedBlockName() {
    if ($("#draft_tiles.draft_selected").length > 0) {
      return 'draft';
    } else {
      return 'suggestion_box';
    }
  }

  function compressSection(animate) {
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
  }


  function compressSectionMargin() {
    var cutHeight, initialHeight;
    initialHeight = section().outerHeight();
    return cutHeight = compressSectionHeight() - initialHeight;
  }

  function compressSectionHeight() {
    return 330;
  }

  function moveBottomBoundOfSection(height) {
    section().css("margin-bottom", height);
  }

  function makeVisibleAllDraftTilesButHideThem() {
    setCompressedSectionClass("remove");
    moveBottomBoundOfSection(compressSectionMargin() + "px");
  }

  function expandSection() {
    var startProgress;
    makeVisibleAllDraftTilesButHideThem();
    startProgress = parseInt(section().css("margin-bottom"));
     animateSectionSliding(-startProgress, startProgress, "down");
  }

  function animateSectionSliding(stepsNum, startProgress, direction) {
    if (direction == null) {
      direction = "down";
    }
    section().addClass("counting");
     $({
      progressCount: 0
    }).animate({
      progressCount: stepsNum
    }, {
      duration: stepsNum,
      easing: 'linear',
      step: function(progressCount) {
        var progressNew;
        progressNew = direction === "down" ? startProgress + parseInt(progressCount) : startProgress - parseInt(progressCount);
         moveBottomBoundOfSection(progressNew + "px");
      },
      complete: function() {
        section().removeClass("counting");
        moveBottomBoundOfSection("");
        if (direction === "down") {
          setCompressedSectionClass("remove");
        } else {
           setCompressedSectionClass("add");
        }
      }
    });
  }

  function scrollUp(duration) {
    if (!iOSdevice()) {
       $('html, body').scrollTo(section(), {
        duration: duration
      });
    }
  }

  function iOSdevice() {
    return navigator.userAgent.match(/(iPad|iPhone|iPod)/g);
  };

  function setCompressedSectionClass(action) {
    if (action == null) {
      action = "remove";
    }
    if (action === "remove") {
      section().removeClass(compressedSectionClass());
    } else {
      section().addClass(compressedSectionClass());
    }
    Airbo.TileDragDropSort.updateTileVisibilityIn(selectedBlockName());
  }

  function sectionIsCompressed() {
    return section().hasClass(compressedSectionClass());
  };

  function compressedSectionClass() {
    return "compressed_section";
  }

  function expandDraftSectionOrSuggestionBox() {
    compressSection();
    $(".all_draft").click(function(e) {
      e.preventDefault();
      if (sectionIsCompressed()) {
        expandSection();
        return $(this).text("Minimize");
      } else {
        compressSection(true);
        return $(this).text("Show all");
      }
    });
  }

  function init(){
    expandDraftSectionOrSuggestionBox();
  }

  return {
    init: init,
    compressSection: compressSection
  };

})();
