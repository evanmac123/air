var Airbo = window.Airbo || {};

Airbo.TileFormModal = (function() {
  var modalId = "tile_form_modal";
  var formSel = "#new_tile_builder_form";
  var pickImageSel = ".image_placeholder, .image_preview.show_shadows";
  var ajaxHandler = Airbo.AjaxResponseHandler;
  var modalObj = Airbo.Utils.StandardModal();
  var self;
  var saveable = false;
  var timer;
  var tileManager;
  var validator;
  var currform;
  var imageLibrary;
  var submitLink;

  function enablesubmitLink() {
    submitLink.removeAttr("disabled");
  }

  function disablesubmitLink() {
    submitLink.attr("disabled", "disabled");
  }

  function setTileCreationPingProps() {
    var props = $.extend({}, Airbo.currentUser, {
      pseudoTileId: Airbo.currentUser.id + "-" + Date.now()
    });
    $("#pseudo_tile_id").data("props", props);
  }

  function getTileCreationPingProps(step) {
    return $.extend({ action: step }, $("#pseudo_tile_id").data("props"));
  }

  function addForceValidation() {
    currform.data("forcevalidation", true);
  }

  function removeForceValidation() {
    currform.data("forcevalidation", false);
  }

  function setAutoSavingTrue() {
    addSavingIndicator();
    currform.data("autosave", true);
  }

  function setAutoSavingFalse() {
    removeSavingIndicator();
    currform.data("autosave", false);
  }

  function resetSubmit() {
    setAutoSavingFalse();
    enablesubmitLink();
  }

  function addSavingIndicator() {
    submitLink.addClass("saving");
  }

  function removeSavingIndicator() {
    submitLink.removeClass("saving");
  }

  function isAutoSaving() {
    return $.active > 0;
  }

  function initFormElements() {
    Airbo.PubSub.unsubscribe("image-selected");
    Airbo.PubSub.unsubscribe("image-done");
    validator = Airbo.TileFormValidator.init(currform);
    Airbo.DirectToS3FileUploader.init();
    Airbo.TileImagePreviewer.init();
    Airbo.TileImageCredit.init();
    Airbo.TileImageFormFields.init();
    Airbo.TilePointsSlider.init();
    Airbo.TileInteractionManager.init();
    Airbo.TileSuportingContentTextManager.init();
    Airbo.Utils.mediumEditor.init();
    Airbo.ImageSearcher.init();
    Airbo.StickyMenu.init(self);
    Airbo.TileBuilderShareToExplore.init();
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      confirmOnClose: false,
      modalClass: "bg-user-side",
      closeSticky: true,
      onOpenedEvent: function() {
        autosize.update($("textarea"));
        currform.data("forcevalidation", tileManager.forceValidationOnNew());
        $("#supporting_content_editor").keyup();
      },
      closeMessage: closeMessage.bind(self)
    });
  }

  function submitSuccess(data) {
    tileManager.refreshOrAddTileThumb(data);
    Airbo.TilePreviewModal.init();
    Airbo.TilePreviewModal.open(data.preview);
  }

  function initEvents() {
    initImageClick();
    initSubmitButtonClick();
    initFormSubmit();
  }

  function initSubmitButtonClick() {
    submitLink.on("click", function(e) {
      e.preventDefault();
      if (isAutoSaving()) return;

      addSavingIndicator();
      currform.submit();
    });
  }

  function initImageClick() {
    currform.on("click", pickImageSel, function(e) {
      e.preventDefault();
    });
  }

  function initFormSubmit() {
    currform.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if (formObj.valid()) {
        disablesubmitLink();
        Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("save"));
        ajaxHandler.submit(formObj, submitSuccess, resetSubmit);
      } else {
        saveable = false;
        removeSavingIndicator();
        validator.focusInvalid();
      }
    });
  }

  function initAutoSave() {
    var me = this;
    if (tileManager.hasAutoSave()) {
      $(currform).on("change", function(event) {
        console.log("change called", event, currform.attr("method"));

        if (isAutoSaving()) {
          console.log("already autosaving");
        }

        setAutoSavingTrue();
        disablesubmitLink();

        if (currform.valid()) {
          modalObj.setConfirmOnClose(false);
          disablesubmitLink();
          timer = setTimeout(function() {
            ajaxHandler.submit(currform, autoSaveSuccess.bind(me), resetSubmit);
          }, 500);
        } else {
          saveable = false;
          modalObj.setConfirmOnClose(true);
          resetSubmit();
        }
      });
    }
  }

  function getTileManager() {
    return tileManager;
  }

  function initVars() {
    currform = $(formSel);
    submitLink = $(".submit_tile_form");
  }

  function openModal() {
    modalObj.open();
  }

  function autoSaveSuccess(data) {
    clearTimeout(timer);
    currform.attr("action", data.updatePath);
    currform.attr("method", "PATCH");
    Airbo.TileManager.refreshOrAddTileThumb(data);
    enablesubmitLink();
    setAutoSavingFalse();
    saveable = true;
  }

  function open(url) {
    $.ajax({
      type: "GET",
      dataType: "JSON",
      url: url,
      success: function(data, status, xhr) {
        modalObj.setContent(data.tileForm);
        initVars();
        initEvents();
        initFormElements();

        if (currform.data("tileid") !== null) {
          initAutoSave();
          saveable = true;
          addForceValidation();
          currform.valid();
        } else {
          modalObj.setConfirmOnClose(true);
        }
        modalObj.open();
        setTileCreationPingProps();
        removeForceValidation();
      }.bind(self),

      error: function(jqXHR, textStatus, error) {
        console.log(error);
      }
    });
  }

  function closeMessage() {
    currform.valid();
    if (saveable === true) {
      return "Your changes have been autosaved. Click 'Cancel' to continuing editing this Tile or Ok to close the Tile Editor.";
    } else {
      return "Are you sure you want to stop editing this Tile? Any changes you've made will be lost.";
    }
  }

  function init(mgr) {
    self = this;
    tileManager = mgr;
    initModalObj();
    Airbo.EmbedVideo.init();
  }

  return {
    init: init,
    open: open,
    openModal: openModal,
    modalId: modalId,
    closeMessage: closeMessage
  };
})();
