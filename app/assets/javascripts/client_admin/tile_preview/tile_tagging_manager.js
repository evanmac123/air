// FIXME extract out all functionality not related to tagging
var Airbo = window.Airbo || {};

Airbo.TileTagger = (function(){
  var addTagClass,
  addTagId,
  shareOptionsAddTag,
  shareToExplore,
  successfulShare,
  selectedTagIds,
  tagList,
  shareOn,
  shareOf,
  publicTileForm,
  sourceSelector,
  targetSelector;

  var config = {
    submitSuccess:  Airbo.Utils.noop,
    submitFail: Airbo.Utils.noop
  };

  function enableShareLink() {
    shareToExplore.removeClass('disabled');
  }

  function disableShareLink() {
    shareToExplore.addClass('disabled');
  }


  function toggleShareRemove(nowPosted) {
    if (nowPosted) {
      shareToExplore.addClass('remove_from_explore outlined yellow').text('Remove from Explore');
    } else {
      shareToExplore.removeClass('remove_from_explore outlined yellow').text('Share to Explore');
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

  function tagIdNotInList(id){
    return tagList.find("#"+id).length === 0;
  }

  function jumpTagSelected(event, ui) {
    event.preventDefault();
    addNewTag(ui.item.value.name);
  }

  function updateTags() {
    submitTileForm();
    addTagId.val("");
  }

  function addNewTag(name) {
    appendSelectedTags(name);
  }

  function appendSelectedTags(name) {
    if (tagIdNotInList(name)) {
      tagList.append("<li data-channel='"+ name +"'><a class='fa fa-times'></a>" + name + "</li>");
      if (selectedTagIds.val() === "") {
        selectedTagIds.val(name);
      } else {
        selectedTagIds.val(selectedTagIds.val() + ("," + name));
      }

      updateTags();
    }
  }


  function initJQueryObjects(){
    addTagClass = $('.add_tag');
    addTagId = $('#add-tag');
    shareOptionsAddTag = $('.share_options .add_tag');
    shareToExplore = $('.share_to_explore');
    successfulShare = $('#successful_share');
    selectedTagIds = $("#tile_public_form_channels");
    tagList = $("ul.tile_tags");
    shareOn = $('#share_on');
    shareOf = $('#share_off');
    publicTileForm = $("#public_tile_form");
    sourceSelector = "#add-tag";
    targetSelector = "#tag-autocomplete-target";
  }

  function initShareToExploreToggleRadioChangeHandler(){
    $('#share_on, #share_off').change(function(event) {
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
      uncheckedRadio.click(); //TODO fix this just set the state
    });
  }

  function undeletedTags(tag){
    var currTags = selectedTagIds.val().split(',');
    return  currTags.filter(function(selected_tag_id) {
      return $.trim(selected_tag_id) !== $.trim(tag);
    });
  }

  function clearTag(element){
    var tags = undeletedTags(element.data('channel'));
    selectedTagIds.val(tags.join(','));
    element.remove();
  }

  function initTagDeletion(){

    $('.add_tag .fa').on('click', function(event) {
      event.preventDefault();
      clearTag($(this).parent());

      submitTileForm();
    });
  }

  function isSharedToExplore(){
    $('#share_on').is(':checked');
  }

  function submitTileForm(){
    publicTileForm.submit();
  }


  function initShareFormSubmission(){
    publicTileForm.on('submit', function(event) {
      event.preventDefault();
      enableShareLink();
      ajaxHandler.submit($(this), config.submitSuccess, config.submitFail);

      return false;
    });
  }

  function initEventHandlers(){
    initShareToExploreToggleRadioChangeHandler();
    initShareToExploreToggle();
    initTagDeletion();
    initShareFormSubmission();
  }

  function init(opts){

    ajaxHandler = Airbo.AjaxResponseHandler;
    config = $.extend(config, opts);
    initJQueryObjects();
    initEventHandlers();
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
    init: init,
  };
}());
