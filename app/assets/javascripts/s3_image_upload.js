var Airbo = window.Airbo || {}
Airbo.DirectToS3ImageUploader = (function(){ 
  var customHandler = {
    added: NOOP,
    progressed: NOOP, 
    processed: NOOP, 
    done: NOOP,
    fileInfo: NOOP
  } 
  , uploaderSelector = "#fileupload"
  , imageUploaderSelector = "#image_uploader"
  , imagePreviewSelector = ".image_preview"
  , uploaderTriggerSelector = "#uploader_trigger"
;

function NOOP(){
  //DOES NOHING
}

function defaultBuiltInPreview(file){
  return file.preview;
}

function imagePreview(data){
  var node, imagePlaceholder, index = data.index || 0, file = data.files[index];
  data.context = $(imageUploaderSelector);
  node = data.context.find(imagePreviewSelector);

  if (defaultBuiltInPreview(file)) {
    //Built-in image preview (scales images)
    node.html(file.preview);
  }else{
    //Manually perform our image preview (no scaling)
    loadImage(file, function (img) { 
      customHandler.processed(img.toDataURL());
    },{canvas: true} );
  }

  if (file.error) {
    node
    .append('<br>')
    .append($('<span class="text-danger"/>').text(file.error));
  }
}

function initChooseFileDelegator(){
  var uploadForm= $(uploaderSelector);

  $('body').on('click',uploaderTriggerSelector, function(event){
    event.preventDefault();
    uploadForm.find('input[type=file]').click();
    return false;
  });
}

function fileProcessed(data){
  data.submit();
  imagePreview(data);
}

function fileAdded(data){
  customHandler.added(data.files[0]);
}

function fileProgress(data){
  var progress;
  if (data.context) {
    progress = parseInt(data.loaded / data.total * 100, 10);
    data.context.find('.bar').css('width', progress + '%');
  }
  customHandler.progressed(data);
}

function fileDone(data){

  var content, domain, file, path, to;
  file = data.files[0];
  domain = $(uploaderSelector).attr('action');
  path = $(uploaderSelector + ' input[name=key]').val().replace('${filename}', file.name);
  customHandler.done(data, file, domain+path);
}

function handleAnyFileErrors(file){
  if(file.error){
    alert("Sorry unable to upload the file due to the following error: " + file.error);
  }
}


function initFileUploader() {

  $(uploaderSelector).fileupload(
    {
      replaceFileInput: true,
      disableImagePreview: true,
      maxFileSize: 2500000, //2.5Mb
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp)$/i,
      messages: {
        acceptFileTypes: 'File type not allowed. Must be a gif, bmp, jpeg, or png image file',
        maxFileSize: 'File is too large. Max File size 2.5Mb',
      }
    }
  ).on('fileuploadadd', function(e, data) {

    fileAdded(data);

  }).on('fileuploadprocessalways', function (e, data) {
    handleAnyFileErrors(data.files[0])
  }).on('fileuploadprocessdone', function (e, data) {
    fileProcessed(data);
  }).on('fileuploadprogress', function(e, data) {
    fileProgress(data);
  }).on('fileuploaddone', function(e, data) {
    fileDone(data);
  }).on('fileuploadfail', function(e, data) {
    var error = "Upload failed due to the following server error: ";
    error += $(data.jqXHR.responseXML).find("Message").text();
    alert(error);
    console.log(data.files[0].name + " " + error);
  });
}

function initCustomHandlers(handler){
  //TODO build this out properly
  return $.extend(customHandler,handler);

} 


function init(handler){
  $('body').off('click', uploaderTriggerSelector);
  initCustomHandlers(handler);
  initChooseFileDelegator();
  initFileUploader();
  Airbo.LoadedSingletonModules.push(this);
}

return {
  init: init
};

}());

