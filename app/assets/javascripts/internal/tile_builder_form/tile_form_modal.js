var Airbo = window.Airbo || {};

Airbo.TileFormModal = (function(){
  // Selectors
  var modalId = "tile_form_modal"
    , formSel ="#new_tile_builder_form"
    , pickImageSel =".image_placeholder, .image_preview.show_shadows"
    , ajaxHandler = Airbo.AjaxResponseHandler
    , self
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
    currform.append("<input type='hidden' name='forcevalidation' id='forcevalidation'/>");
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
      }
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
      currform.submit();
    });

    currform.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if(formObj.valid()){
        disablesubmitLink();
        Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("save"));
        ajaxHandler.submit(formObj, submitSuccess, enablesubmitLink);
      }else{
        validator.focusInvalid();
      }
    });
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
  }

  function initAutoSave(){
    var me = this;
    $(currform).on("change", function() {
      if(currform.valid()){
        disablesubmitLink()
        ajaxHandler.submit(currform, autoSaveSuccess.bind(me), $.noop);
      }
    });

  }


  function removeForceValidation(){
    $("#forcevalidation", currform).remove();
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
        addForceValidation();
        modalObj.open();
        triggerMixpanelTileCreateDurationTracking();
        currform.valid();
        initAutoSave();
        removeForceValidation();
      }.bind(self),

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
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
    modalId: modalId
  }
}());
