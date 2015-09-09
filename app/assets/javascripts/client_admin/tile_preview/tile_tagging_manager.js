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
    , selectedTagIds
    , tagList
    , searchURL
    , publicTileForm
    , tagAlert
    , appliedTags
    , ajaxHandler
    , sourceSelector = "#add-tag"
    , targetSelector = "#tag-autocomplete-target"
    , shareOptionsSelector = '.share_options'
    , allowCopyingSelector = '.allow_copying'
    , allowCopySelector = '.allow_copy'
    , allowCopyingOnSelector = '#allow_copying_on'
    , allowCopyingOffSelector =  '#allow_copying_off'
    , allowCopyingToggleSelector = '#allow_copying_on, #allow_copying_off'
    , addTagClassSelector = '.add_tag'
    , addTagIdSelector = '#add-tag'
    , shareOptionsAddTagSelector = '.share_options .add_tag'
    , shareToExploreSelector = '.share_to_explore'
    , shareOnSelector = '#share_on'
    , shareOffSelector = '#share_off'
    , shareOnOffToggleSelector ='#share_on, #share_off'
    , successfulShareSelector = '#successful_share'
    , selectedTagIdsSelector = "#tile_public_form_tile_tag_ids"
    , tagListSelector = "ul.tile_tags"
    , publicTileFormSelector = "#public_tile_form"
    , tagAlertSelector = ".tag_alert"
    , appliedTagsSelector = ".tile_tags li"
    , selectedTagsCache = {}
  ;

  var config = {
    submitSuccess: Airbo.Utils.noop,
    submitFail: Airbo.Utils.noop
  }

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
    enableShareLink(); // TODO very if of to remove this functionality from tile tagging and sharing to explore
    enableCopySwitch();
    if (startedWithNoTags) {
     allowCopyingOn.click();
    }
    event.preventDefault();
  }

  function unhighlightAddTag() {
    addTagId.removeClass('highlighted');
  }

  function highlightAddTag() {
    addTagId.addClass('highlighted');
  }

  function noTags() {
    $('.tile_tags a').length === 0;
  }

  function enableShareLink() {
    shareToExplore.removeClass('disabled');
  }

  function disableShareLink() {
    shareToExplore.addClass('disabled');
  }

  function enableCopySwitch() {
    allowCopy.removeClass('disabled');
  }

  function disableCopySwitch() {
    allowCopy.addClass('disabled');
  }

  function toggleShareRemove(nowPosted) {
    if (nowPosted) {
      shareToExplore.addClass('remove_from_explore').text('Remove from Explore');
    } else {
      shareToExplore.removeClass('remove_from_explore').text('Share to Explore');
    }
    return true;
  }

  function toggleSuccessVisibility(nowPosted) {
    if (nowPosted) {
      successfulShare.show();
    } else {
      successfulShare.hide();
    }
  }

  function addNewTag(name) {
    $.ajax({
      url: "/client_admin/tile_tags/add?term=" + name,
      success: function(id) {
        appendSelectedTags(id, name);
        tagList.addClass("has_tags");
      }
    });
  }


  function tileTagsError() {
    //This condition cannot be met
    return $('#sharable_tile_link_on').is(':checked') && $('#share_on').is(':checked') && ('.tile_tags li').length < 1;
  }

  function tagIdNotInList(id){
    return tagList.find("#"+id).length === 0;
  }

  function addToSelectedTagsCache(id, name){
    //selectedTagsCache[id]=name;
  }

  function removeFromSelectedTagsCache(id){
    //delete selectedTagsCache[id];
  }

  function appendSelectedTags(id, name) {
    publicTileForm.find('.tag_alert').hide();
    addToSelectedTagsCache(id, name);

    if (tagIdNotInList(id)) {

      tagList.append("<li id='" + id + "'>" + name + "<a class='fa fa-times'></a> </li>");

      if (selectedTagIds.val() === "") {
        selectedTagIds.val(id);
      } else {
        selectedTagIds.val(selectedTagIds.val() + ("," + id));
      }
    }
    submitTileForm();
  }


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
    selectedTagIds = $(selectedTagIdsSelector);
    tagList = $(tagListSelector);
    shareOn = $(shareOnSelector);
    shareOf = $(shareOffSelector);
    publicTileForm = $(publicTileFormSelector);
    tagAlert = $(tagAlertSelector);
    appliedTags = $(appliedTagsSelector);
  }

  function initShareToExploreToggleRadioChangeHandler(){
    $(shareOnOffToggleSelector).change(function(event) {
      var switchedToOn;
      submitTileForm();
      switchedToOn = $(event.target).val() === 'true';
      toggleShareRemove(switchedToOn);
      toggleSuccessVisibility(switchedToOn);
    });
  }

  function initShareToExploreToggle(){

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
  }

  function initAllowCopyingToggle(){

    $(allowCopyingToggleSelector).click(function(event) {
      submitTileForm();
    });
  }

  function initPageUnloadWarning(){
    $(window).on("beforeunload", function() {
      if (tileTagsError()) {
        tagAlert.show();
        return "If you leave this page, you’ll lose any changes you made. Please, save them before leaving.";
      }
    });
  }


  function initNavigateAwayWarning(){
    $("#archive, #post, .edit_header a, .new_tile_header a").click(function(e) {
      if (tileTagsError()) {
        e.preventDefault();
        e.stopPropagation();
        tagAlert.show();
      }
    });
  }

  function isLastTag(){
    return $('.add_tag li').length === 1 && $('#share_on:checked').length > 0
  }

  function undeletedTags(tagId){
    var currTags = selectedTagIds.val().split(',');
    return  currTags.filter(function(selected_tag_id) {
      return selected_tag_id !== tagId;
    });
  }

  function clearTag(element){
    var tags = undeletedTags(element.attr('id'));

    selectedTagIds.val(tags.join(','));
    element.remove();
  }

  function initTagDeletion(){

    $('.add_tag .fa').on('click', function(event) {
      event.preventDefault();
      if (isLastTag()) {
        tagAlert.show();
      }else{
        clearTag($(this).parent());
        tagAlert.hide();

        if (noTags()) {
          highlightAddTag();
          disableShareLink();
          disableCopySwitch();
        }
        submitTileForm();
      }
    });
  }

  function isSharedToExplore(){
    $('#share_on').is(':checked');
  }

  function isValidToShareToExplore(){
    if (isSharedToExplore()) {
      if (appliedTags.length < 1) {
        return false;
      } else {
        tagAlert.hide();
        return true;
      }
    } else {
      return true;
    }
  }

  function submitTileForm(){
    publicTileForm.submit();
  }


  function initShareFormSubmission(){
    publicTileForm.on('submit', function(event) {
      event.preventDefault();
      if (isValidToShareToExplore()){
        ajaxHandler.submit($(this), config.submitSuccess, config.submitFail);
      }
    });
  }

  function initEventHandlers(){
    initAllowCopyingToggle();
    initShareToExploreToggleRadioChangeHandler();
    initShareToExploreToggle();
    initPageUnloadWarning();
    initNavigateAwayWarning();
    initTagDeletion();
    initShareFormSubmission();
  }


  function setTagsCache(){
    appliedTags.each(function(idx, o){
      var obj = $(o)
        , id =obj.attr("id")
        , name = obj.text().trim()
      ;

      addToSelectedTagsCache(id,name);
    });
  }

  function init(opts){

    ajaxHandler = Airbo.AjaxResponseHandler;
    config = $.extend(config, opts)
    initJQueryObjects();
    initEventHandlers();
    setTagsCache();
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

