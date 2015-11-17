//= require jquery
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require ../../../vendor/assets/javascripts/autosize
//= require ../../../vendor/assets/javascripts/sweetalert/sweetalert.min


//FIXME add to airbo utils
function isIE11() {
  return !!window.MSInputMethodContext;
};

function isIE() {
  var myNav;
  myNav = navigator.userAgent.toLowerCase();
  if (myNav.indexOf('msie') !== -1) {
    return parseInt(myNav.split('msie')[1]);
  } else if (isIE11()) {
    return 11;
  } else {
    return false;
  }
};




var Airbo = window.Airbo || {};

//FIXME Remove Deprecated PAGes features

Airbo.Utils = {




  supportsFeatureByPresenceOfSelector: function(identifier){
    return $(identifier).length > 0
  },

  Pages: {
    TILE_BUILDER: "#new_tile_builder_form",
    TILE_STATS_CHART: "#new_tile_stats_chart_form",
    TILE_STATS_GRID: "#tile_stats_grid",
    SURVEY_TABLE: "#survey_table"
  },

  isAtPage: function(identifier){
    return $(identifier).length > 0
  },

  noop:  function(){},

  urlParamValueByname: function getQueryVariable(variable){
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if(pair[0] == variable){
        return pair[1];
      }
    }
    return(false);
  },

  validationConfig: {

    errorPlacement: function(error, element) {
      element.parent().append(error);
    },

    errorClass: "err",

    errorElement: "label",

    highlight: function(element, errorClass, validClass) {
      $(element).addClass("error").removeClass(errorClass);
    },

    unhighlight: function(element, errorClass, validClass) {
      $(element).removeClass("error");
    }
  },

  confirmWithRevealConfig: {
    modal_class: 'tiny confirm-with-reveal destroy_confirm_modal',
    ok_class: 'confirm',
    cancel_class: 'cancel',
    password: false,
    title: "",
    reverse_buttons: true
  },

  mediumEditor:  (function() {
    var editor, field, fieldName;

    function reset(){
      if(editor){
        editor.destroy();
      }
    }

    function init(params) {
      params = params || {};
      reset();

      $('.medium-editable').each(function(){

        defaultParams = {
          staticToolbar:true,
          buttonLabels: 'fontawesome',
          targetBlank: true,
          anchor: {
           linkValidation: true,
          },
          toolbar: {
           buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor"]
          }
        };
        editor = new MediumEditor(this, $.extend(defaultParams, params) );
        editor.trigger("focus");

        fieldName = $(this).data('field')
        field = $("#" + fieldName);

        //$(this).html($("#" + $(this).data("field")).val());
        content =  $("#" + $(this).data("field")).val();

        editor.setContent(content);

        editor.subscribe('editableInput', function (event, editable) {
          var obj =$(editable),  textLength = obj.text().trim().length;

          if(textLength > 0){
            field.val(obj.html());
          }else{
            field.val("");
          }

          field.blur();
        });

      })
    }

    return {
      init: init
    };

  }())

}

Airbo.Utils.TextSelectionDetector = (function(){
  var eventTarget, callback;

  function initAutoSelect(cb){
    eventTarget.click(function(){
      $(this).select();
      cb();
    });
  }

  function init(targetSelector, cb){
    eventTarget = $(targetSelector);
    initAutoSelect(cb);
  }

  return {
    init: init
  };

}());


Airbo.Utils.TilePlaceHolderManager = (function(){

  var placeholderSelector =".tile_container.placeholder_container:not(.hidden_tile)"
    , notDraggedTileSelector = ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)"
    , sectionNames = ["draft", "active", "archive", "suggestion_box"]
    , placeholderHTML = '<div class="tile_container placeholder_container">' + 
  '<div class="tile_thumbnail placeholder_tile"></div></div>' 
;


  function updateNoTilesSection(section) {
    var no_tiles_section;
    no_tiles_section = $("#" + section).find(".no_tiles_section");
    if ($("#" + section).children(notDraggedTileSelector).length === 0) {
      return no_tiles_section.show();
    } else {
      return no_tiles_section.hide();
    }
  };

  function numberInRow(section) {
    if (section === "draft" || section === "suggestion_box") {
      return 6;
    } else {
      return 4;
    }
  };

  /*TODO refactor and combine these three functions
   * updateAllNoTilesSections
   * updateTileVisibility
   * updateAllPlaceholders
  */

  function updateAllNoTilesSections() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updateNoTilesSection(section));
    }
    return results;
  };

  function updateTileVisibility() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updateTileVisibilityIn(section));
    }
    return results;
  }; 

  function updateAllPlaceholders() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updatePlaceholders(section));
    }

    return results;
  }

  function visibleTilesNumberIn(section) {
    if (section === "draft" || section === "suggestion_box") {
      if (draftSectionIsCompressed()) {
        return numberInRow(section);
      } else {
        return 9999;
      }
    } else if (section === "archive") {
      return numberInRow(section);
    } else {
      return 9999;
    }
  };

  function updateTileVisibilityIn(section) {
    var i, index, len, results, tile, tiles, visibleTilesNumber;
    tiles = $("#" + section).find("> " + notDraggedTileSelector);
    visibleTilesNumber = visibleTilesNumberIn(section);
    results = [];
    for (index = i = 0, len = tiles.length; i < len; index = ++i) {
      tile = tiles[index];
      if (index < visibleTilesNumber) {
        results.push($(tile).css("display", "block"));
      } else {
        results.push($(tile).css("display", "none"));
      }
    }
    return results;
  };


  function draftSectionIsCompressed() {
    return $("#draft_tiles").hasClass("compressed_section");
  };

  function updatePlaceholders(section) {
    var allTilesNumber, expectedPlaceholdersNumber, placeholdersNumber, tilesNumber;

    allTilesNumber = $("#" + section).find(notDraggedTileSelector).length;
    placeholdersNumber = $("#" + section).find(placeholderSelector).length;
    tilesNumber = allTilesNumber - placeholdersNumber;

    expectedPlaceholdersNumber = (numberInRow(section) - (tilesNumber % numberInRow(section))) % numberInRow(section);

    removePlaceholders(section);
    addPlaceholders(section, expectedPlaceholdersNumber);

  };


  function removePlaceholders(section) {
    $("#" + section).children(placeholderSelector).remove();
  }

  function addPlaceholders(section, number) {
    $("#" + section).append(placeholderHTML.times(number));
  }


  function updateTilesAndPlaceholdersAppearance() {
    updateAllPlaceholders();
    updateAllNoTilesSections();
    updateTileVisibility();
  }

  function init(){
   //noop
  }
  return {
    init: init,
    updateTilesAndPlaceholdersAppearance: updateTilesAndPlaceholdersAppearance 
  };

}());




Airbo.Utils.PluginExtentions = (function(){

  function forJQueryValidator(){

    function addMaxTextLength(){
      $.validator.addMethod("maxTextLength", function(value, element, param) {

        function textLength(value){
          var length = 0, content= $("<div></div>");
          content.html(value).each(function(idx, obj){
            length += $(obj).text().length;
          })

          return length;
        }
        return this.optional(element) || textLength(value) <= param;
      }, jQuery.validator.format("Character Limit Reached"));
    }

    /* --------INVOKE INDIVIDUAL VALIDATOR EXTENSIONS HERE---------------*/
    addMaxTextLength();

  }

  function init(){
    forJQueryValidator();
  }
 return {
  init: init
 }

}());

$(function(){
  Airbo.Utils.PluginExtentions.init();
})

//FIXME Deprecated
Airbo.LoadedSingletonModules = [];


