var Airbo = window.Airbo || {};

Airbo.TileAttachmentUploader = (function() {
  var initialized
    ,  eventPrefix = "/s3/tileAttachment/upload/"
    , attachment_list = $('#attachment_list')
;

  function setFormFieldsForAttachment() {
  }

  function fileAdded(event, data){
    //no op
  }

  function fileProcessed(event, data){
    data.submit();
  }

  function fileProgress(event, data){
    var progress;
    if (data.context) {
      progress = parseInt(data.loaded / data.total * 100, 10);
    }
  }

  function fileDone(event, data){
    var content
      , domain
      , file
      , path
      , to
    ;

    file = data.files[0];
    domain = $("#file-uploader").attr('action');
    path = $("#file-uploader" + ' input[name=key]').val().replace('${filename}', file.name);
    fullPath = domain + path
    addAttachmentLink(file.name, fullPath);
  }

  function addAttachmentLink(name,fullPath){
    var link = $("<a class='attachment-link'>")
      ,  attachment = $("<div class='tile-attachment'>")
      ,  field = createAttachmentField(name, fullPath)
    ;

    link.attr("href", fullPath);
    link.append("<i class='fa fa-file-o icon-tile-attachment'></i>");
    link.append("<div class='attachment-filename'>"+ name + "</div>");

    attachment.append(field);
    attachment.append(link);
    attachment.append("<i class='fa fa-times-circle attachment-delete'></i><br/>");
    $(".attachment-list").append(attachment);
  }

  function createAttachmentField(name, path){
    var field = $('<input type="hidden" name="tile[attachments][]"/>')
    ;
    field.val(path);
    field.attr("id", name.replace(/ /g,"_"));
    return field;
  }

  function allCompleted(){
    var form = $("#new_tile_builder_form");
    form.trigger("change")
  }


  function initDeleteAttachment(){

    $("body").on("click", ".attachment-delete", function(){
      var attachment =$(this).parents(".tile-attachment")
        , key = attachment.data("key")
        , fieldSel = "input[id='" + key + "']"
        , field = attachment.find("input[name='tile[attachments][]']")
        ,  form = $("#new_tile_builder_form")
      ;

      field.remove();
      attachment.remove();
      //NOTE we are not handling the case where user uploads but never saves the tile
      //in which case the tile will be have the right attachmens eventually but
      //the file will remain in S3 
      form.trigger("change")
    })
  }



  function initUploadEventSubscription(){
    Airbo.PubSub.subscribe(eventPrefix + "added", fileAdded);
    Airbo.PubSub.subscribe(eventPrefix + "processed", fileProcessed);
    Airbo.PubSub.subscribe(eventPrefix + "progress", fileProgress);
    Airbo.PubSub.subscribe(eventPrefix + "done", fileDone);
    Airbo.PubSub.subscribe(eventPrefix + "stop", allCompleted);
  }


  function init(){
    initUploadEventSubscription()
    initDeleteAttachment();
    return this;
  }

  return {
    init: init
  };

}());
