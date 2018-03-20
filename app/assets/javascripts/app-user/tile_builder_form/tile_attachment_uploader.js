var Airbo = window.Airbo || {};

Airbo.TileAttachmentUploader = (function() {
  var initialized;
  var eventPrefix = "/s3/tileAttachment/upload/";
  var attachment_list = $("#attachment_list");

  function setFormFieldsForAttachment() {}

  function fileAdded(event, data) {
    //no op
  }

  function fileProcessed(event, data) {
    data.submit();
  }

  function fileProgress(event, data) {
    var progress;
    if (data.context) {
      progress = parseInt(data.loaded / data.total * 100, 10);
    }
  }

  function fileDone(event, data) {
    var content;
    var domain;
    var file;
    var path;
    var to;

    file = data.files[0];
    domain = $("#file-uploader").attr("action");
    path = $("#file-uploader" + " input[name=key]")
      .val()
      .replace("${filename}", file.name);
    fullPath = domain + path;
    addAttachmentLink(file.name, fullPath);
  }

  function addAttachmentLink(name, fullPath) {
    var attachment = $(".tile-attachment.hidden-template").clone();
    var field = createAttachmentField(name, fullPath);

    attachment.removeClass("hidden-template");
    attachment.append(field);
    attachment.find(".attachment-filename").text(name);
    attachment.find(".attachment-link").attr("href", fullPath);
    $(".attachment-list").append(attachment);
  }

  function createAttachmentField(name, path) {
    var field = $('<input type="hidden" name="tile[attachments][]"/>');
    field.val(path);
    field.attr("id", name.replace(/ /g, "_"));
    return field;
  }

  function allCompleted() {
    var form = $("#new_tile_builder_form");
    form.trigger("change");
  }

  function initDeleteAttachment() {
    $("body").on("click", ".attachment-delete", function() {
      var attachment = $(this).parents(".tile-attachment");
      var key = attachment.data("key");
      var fieldSel = "input[id='" + key + "']";
      var field = attachment.find("input[name='tile[attachments][]']");
      var form = $("#new_tile_builder_form");

      field.remove();
      attachment.remove();
      //NOTE we are not handling the case where user uploads but never saves the tile
      //in which case the tile will be have the right attachmens eventually but
      //the file will remain in S3
      form.trigger("change");
    });
  }

  function initUploadEventSubscription() {
    Airbo.PubSub.subscribe(eventPrefix + "added", fileAdded);
    Airbo.PubSub.subscribe(eventPrefix + "processed", fileProcessed);
    Airbo.PubSub.subscribe(eventPrefix + "progress", fileProgress);
    Airbo.PubSub.subscribe(eventPrefix + "done", fileDone);
    Airbo.PubSub.subscribe(eventPrefix + "stop", allCompleted);
  }

  function init() {
    initUploadEventSubscription();
    initDeleteAttachment();
    return this;
  }

  return {
    init: init
  };
})();
