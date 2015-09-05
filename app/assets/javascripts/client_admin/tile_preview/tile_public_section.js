var Airbo = window.Airbo || {};

Airbo.TileTagger = (function(){
  var  shareOptions
    , allowCopying
    , allowCopy
    , allowCopyingOn
    , allowCopyingOff
    , addTagClass
    , addTagId
    , shareOptionsAddTag
    , shareToExplore
    , shareOn
    , shareOff
    , successfulShare
    , tilePublicFormTileTagIds
    , tileTagIds
    , searchURL
    , publicTileForm
    , sourceSelector = "#add-tag"
    , targetSelector = "#tag-autocomplete-target"
    , shareOptionsSelector = '.share_options'
    , allowCopyingSelector = '.allow_copying'
    , allowCopySelector = '.allow_copy'
    , allowCopyingOnSelector = '#allow_copying_on'
    , allowCopyingOffSelector =  '#allow_copying_off'
    , addTagClassSelector = '.add_tag'
    , addTagIdSelector = '#add-tag'
    , shareOptionsAddTagSelector = '.share_options .add_tag'
    , shareToExploreSelector = '.share_to_explore'
    , shareOnSelector = '#share_on'
    , shareOffSelector = '#share_off'
    , successfulShareSelector = '#successful_share'
    , tilePublicFormTileTagIdsSelector = "#tile_public_form_tile_tag_ids"
    , tileTagIdsSelector = "ul.tile_tags"
    , publicTileFormSelector = "#public_tile_form"
  ;


  function initialSetting() {
        //tilePublicFormTileTagIds.hide();
  };


  function jumpTagSelected(event, ui) {
    var startedWithNoTags;
    startedWithNoTags = noTags();
    if (ui.item.value.found) {
      appendSelectedTags(ui.item.value.id, ui.item.label);
    } else {
      addNewTag(ui.item.value.name);
    }
    addTagId.val("");
    unhighlightAddTag();
    enableShareLink();
    enableCopySwitch();
    if (startedWithNoTags) {
      $('#allow_copying_on').click();
    }
    event.preventDefault();
  };

  function unhighlightAddTag() {
    addTagId.removeClass('highlighted');
  };

  function highlightAddTag() {
    addTagId.addClass('highlighted');
  };

  function noTags() {
    $('.tile_tags a').length === 0;
  };

  function enableShareLink() {
    shareToExplore.removeClass('disabled');
  };

  function disableShareLink() {
    shareToExplore.addClass('disabled');
  };

  function enableCopySwitch() {
    allowCopy.removeClass('disabled');
  };

  function disableCopySwitch() {
    allowCopy.addClass('disabled');
  };

  function toggleShareRemove(nowPosted) {
    if (nowPosted) {
      shareToExplore.addClass('remove_from_explore').text('Remove from Explore');
    } else {
      shareToExplore.removeClass('remove_from_explore').text('Share to Explore');
    }
    return true;
  };

  function toggleSuccessVisibility(nowPosted) {
    if (nowPosted) {
      $('#successful_share').show();
    } else {
      $('#successful_share').hide();
    }
  };

  function addNewTag(name) {
    $.ajax({
      url: "/client_admin/tile_tags/add?term=" + name,
      success: function(id) {
        appendSelectedTags(id, name);
      }
    });
  };


  function tileTagsError() {
    return $('#sharable_tile_link_on').is(':checked') && $('#share_on').is(':checked') && shareOptions.find('.tile_tags li').length < 1;
  };

  function appendSelectedTags(id, name) {
    publicTileForm.find('.tag_alert').hide();
    if ($('ul.tile_tags > li[id=' + id + ']').length < 1) {
      $('ul.tile_tags').append("<li id='" + id + "'>" + name + "<a class='fa fa-times'></a> </li>");
      if ($('#tile_public_form_tile_tag_ids').val() === "") {
        $('#tile_public_form_tile_tag_ids').val(id);
      } else {
        $('#tile_public_form_tile_tag_ids').val($('#tile_public_form_tile_tag_ids').val() + ("," + id));
      }
    }
    publicTileForm.submit();
  };


  function initJQueryObjects(){
    shareOptions = $(shareOptionsSelector);
    allowCopying = $(allowCopyingSelector);
    allowCopy = $(allowCopySelector);
    allowCopyingOn = $(allowCopyingOnSelector);
    allowCopyingOff =  $(allowCopyingOffSelector);
    addTagClass = $(addTagClassSelector);
    addTagId = $(addTagIdSelector);
    shareOptionsAddTag = $(shareOptionsAddTagSelector);
    shareToExplore = $(shareToExploreSelector);
    successfulShare = $(successfulShareSelector);
    tilePublicFormTileTagIds = $(tilePublicFormTileTagIdsSelector);
    tileTagIds = $(tileTagIdsSelector);
    shareOn = $(shareOnSelector);
    shareOf = $(shareOffSelector);
    publicTileForm = $(publicTileFormSelector);
  }


  function initHandlers(){
    $('#allow_copying_on, #allow_copying_off').click(function(event) {
      publicTileForm.submit();
    });

    $('#share_off, #share_on').change(function(event) {
      var switchedToOn;
      publicTileForm.submit();
      switchedToOn = $(event.target).val() === 'true';
      toggleShareRemove(switchedToOn);
      toggleSuccessVisibility(switchedToOn);
    });

    shareToExplore.click(function(event) {
      var shareRadios, uncheckedRadio;
      event.preventDefault();
      if (shareToExplore.hasClass('disabled')) {
        return;
      }
      shareRadios = $('#share_to_explore_buttons input[type=radio]');
      uncheckedRadio = shareRadios.not(':checked').first();
      uncheckedRadio.click();
    });

    $(window).on("beforeunload", function() {
      if (tileTagsError()) {
        $('.tag_alert').show();
        return "If you leave this page, you’ll lose any changes you made. Please, save them before leaving.";
      }
    });

    $("#back_header a, #archive, #post, .edit_header a, .new_tile_header a").click(function(e) {
      if (tileTagsError()) {
        e.preventDefault();
        e.stopPropagation();
        $('.tag_alert').show();
      }
    });

    $(document).on('click', '.add_tag .fa', function(event) {
      var element, filtered_vals, tag_id, vals;
      if ($('.add_tag li').length === 1 && $('#share_on:checked').length > 0) {
        $('.tag_alert').show();
        return false;
      }
      element = $(this).parent();
      tag_id = element.attr('id');
      vals = shareOptions.find('#tile_public_form_tile_tag_ids').val().split(',');
      filtered_vals = vals.filter(function(selected_tag_id) {
        return selected_tag_id !== tag_id;
      });

      shareOptions.find('#tile_public_form_tile_tag_ids').val(filtered_vals.join(','));
      element.remove();

      $('.tag_alert').hide();

      if (noTags()) {
        highlightAddTag();
        disableShareLink();
        disableCopySwitch();
      }
      publicTileForm.submit();
    });

    publicTileForm.on('submit', function(event) {
      event.preventDefault();
      if ($(this).find('#share_on').is(':checked')) {
        if ($(this).find('.share_options').find('.tile_tags li').length < 1) {
          return false;
        } else {
          $(this).find('.tag_alert').hide();
          return true;
        }
      } else {
        return true;
      }
    });
  }


  function init(){
    initJQueryObjects();
    initHandlers();
    searchURL = $(sourceSelector).data("searchurl");

    $(sourceSelector).autocomplete({
      appendTo: targetSelector,
      source: searchURL,
      html: 'html',
      select: jumpTagSelected,
      focus: function(event) {
        event.preventDefault();
      }
    });
  }

  return {
    init: init
  };


}());



window.bindTagNameSearchAutocomplete = function(sourceSelector, targetSelector, searchURL) {

};

