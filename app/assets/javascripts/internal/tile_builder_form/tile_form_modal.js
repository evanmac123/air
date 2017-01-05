var Airbo = window.Airbo || {};

Airbo.TileFormModal = (function(){
  // Selectors
  var modalId = "tile_form_modal"
    , formSel ="#new_tile_builder_form"
    , pickImageSel =".image_placeholder, .image_preview.show_shadows"
    , ajaxHandler = Airbo.AjaxResponseHandler
    , self
    , saveable = false
  ;

  var modalObj = Airbo.Utils.StandardModal()
    , tileManager
    , validator
    , currform
    , imageLibrary
    , submitLink
  ;

  function enablesubmitLink(){
    submitLink.removeAttr("disabled");
  }

  function disablesubmitLink(){
    submitLink.attr("disabled", "disabled");
  }

  function tileContainerSizes() {
    tileContainer = $(".tile_holder_container")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }

  function setTileCreationPingProps(){
    var props =$.extend({}, Airbo.currentUser, {pseudoTileId: Airbo.currentUser.id + "-" + Date.now() });
    $("#pseudo_tile_id").data("props", props);
  }

  function triggerMixpanelTileCreateDurationTracking(){
    setTileCreationPingProps();
    Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("start"));
  }

  function getTileCreationPingProps(step){
    return $.extend({"action": step}, $("#pseudo_tile_id").data("props"));
  }

  function addForceValidation(){
    currform.data("forcevalidation", true);
  }

  function removeForceValidation(){
    currform.data("forcevalidation", false);
  }

  function addAutoSave(){
    addSavingIndicator();
    currform.data("autosave", true);
  }

  function removeAutoSave(){
    removeSavingIndicator();
    currform.data("autosave", false);
  }

  function resetSubmit(){
    removeAutoSave();
    enablesubmitLink();
  }

  function addSavingIndicator(){
    submitLink.addClass("saving");
  }


  function removeSavingIndicator(){
    submitLink.removeClass("saving");
  }

  function initFormElements() {
    validator = Airbo.TileFormValidator.init(currform);
    Airbo.TileImagesMgr.init();
    Airbo.TileImageCredit.init();
    Airbo.TilePointsSlider.init();
    Airbo.TileQuestionBuilder.init();
    Airbo.TileSuportingContentTextManager.init();
    Airbo.Utils.mediumEditor.init();
    imageLibraryModal = Airbo.ImageLibraryModal;
    imageLibraryModal.init(Airbo.TileFormModal);
    Airbo.StickyMenu.init(self);
    Airbo.EmbedVideo.initForm();

    $("#upload_preview").on("load", function(){
      $(".image_preview").removeClass("loading").attr("style", ""); // remove height
    });
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      confirmOnClose: true,
      modalClass: "bg-user-side",
      closeSticky: true,
      onOpenedEvent: function() {
        autosize.update( $('textarea') );
      },
      closeMessage: closeMessage.bind(self) ,
    });
  }

  function submitSuccess(data) {

    tileManager.updateSections(data);

    var tilePreview = Airbo.TilePreviewModal;
    tilePreview.init();
    tilePreview.open(data.preview);
  }

  function initEvents() {
    currform.on("click", pickImageSel, function(e){
      e.preventDefault();
      Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("add image"));
      var libraryUrl = $("#image_uploader").data("libraryUrl");
      imageLibraryModal.open(libraryUrl);
    });

    submitLink.click(function(e){
      e.preventDefault();
      if($(this).attr("disabled") === "disabled"){
        return;
      }
      addSavingIndicator();
      currform.submit();
    });

    currform.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if(formObj.valid()){
        disablesubmitLink();
        Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("save"));
        ajaxHandler.submit(formObj, submitSuccess, resetSubmit);
      }else{
        saveable = false;
        removeSavingIndicator();
        validator.focusInvalid();
      }
    });
  }

  function initAutoSave(){
    var me = this;
    if(currform.data("suggested") === false){
      $(currform).on("change", function() {

        addAutoSave();
        disablesubmitLink()
        if(currform.valid()){
          disablesubmitLink()
          ajaxHandler.submit(currform, autoSaveSuccess.bind(me), resetSubmit);
        }else{
          saveable = false;
          resetSubmit();
        }
      });
    }
  }


  function initVars() {
    currform = $(formSel);
    submitLink = currform.find(".submit_tile_form");
  }

  function openModal(){
    modalObj.open();
  }

  function updateThumbnail(data){
    tileManager.updateSections(data);
  }

  function autoSaveSuccess(data){
    currform.attr("action", data.updatePath);
    currform.attr("method", "PUT");

    updateThumbnail(data)
    enablesubmitLink();
    removeAutoSave();
    saveable = true;
  }






  function open(url) {
    $.ajax({
      type: "GET",
      dataType: "html",
      url: url,
      success: function(data, status,xhr){
        modalObj.setContent(data);
        initVars();
        initEvents();
        initFormElements();
        if(currform.data("tileid") !== null) {
          saveable = true;
          addForceValidation();
          currform.valid();
        }
        modalObj.open();
        triggerMixpanelTileCreateDurationTracking();
        initAutoSave();
        removeForceValidation();
      }.bind(self),

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function closeMessage(){
    currform.valid();
    if(saveable == true){
      return "Your changes have been autosaved. Click 'Cancel' to continuing editing this Tile or Ok to close the Tile Editor.";
    }else{
      return "Are you sure you want to stop editing this Tile. All of your changes will be lost."
    }

  }

  function init(mgr) {
    self = this;
    initModalObj();
    tileManager = mgr;
    Airbo.EmbedVideo.init();
  }

  return {
    init: init,
    open: open,
    openModal: openModal,
    tileContainerSizes: tileContainerSizes,
    modalId: modalId,
    closeMessage: closeMessage
  }
}());
