var Airbo = window.Airbo || {}
Airbo.DirectToS3ImageUploader = (function(){ 
  var NOOP = function(){},
    customHandler = {
    added: NOOP,
    progressed: NOOP, 
    processed: NOOP, 
    done: NOOP,
    fileInfo: NOOP
  };

  function defaultBuiltInPreview(file){
    return file.preview;
  }

  function imagePreview(data){
    var node, imagePlaceholder, index = data.index || 0, file = data.files[index];
    data.context = $("#image_uploader");
    node = data.context.find(".image_preview");

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
    var uploadForm= $("#fileupload");

    $('body').on('click', ".upload_image", function(event){
      event.preventDefault();
      uploadForm.find('input[type=file]').click();
      return false;
    });
  }

  function fileProcessed(data){
    imagePreview(data);
  }

  function fileAdded(data){
    var file = data.files[0],
      types = /(\.|\/)(gif|jpe?g|png|bmp)$/i;

      if (types.test(file.type) || types.test(file.name)) {
        data.submit();
      } else {
        alert(file.name + " is not a gif, jpeg, or png image file");
      }
      customHandler.added(file);
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
    domain = $('#fileupload').attr('action');
    path = $('#fileupload input[name=key]').val().replace('${filename}', file.name);
    customHandler.done(data, file, domain+path);
  }

  function initFileUploader() {

    $('#fileupload').fileupload(
      {
        replaceFileInput: false,
        disableImagePreview: true
      }
    ).on('fileuploadadd', function(e, data) {
      fileAdded(data);
    }).on('fileuploadprocessalways', function (e, data) {
      fileProcessed(data);
    }).on('fileuploadprogress', function(e, data) {
      fileProgress(data);
    }).on('fileuploaddone', function(e, data) {
      fileDone(data);
    }).on('fileuploadfail', function(e, data) {
      console.log(data.files[0].name + " failed to upload.");
    });
  }

  function initCustomHandlers(handler){
    //TODO build this out properly
    return $.extend(customHandler,handler);

  } 


  function init(handler){
    initCustomHandlers(handler);
    initChooseFileDelegator();
    initFileUploader();
  }

  return {
    init: init
  };

}());

