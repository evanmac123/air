var Airbo = window.Airbo || {}
Airbo.DirectToS3FileUploader = (function(){

  var uploadTypes ={
    tileImage:{
      maxFileSize: 2500000,
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp)$/i,
      messages: {
        acceptFileTypes: 'File type not allowed. Must be a gif, bmp, jpeg, or png image file',
        maxFileSize: 'File is too large. Max File size 2.5Mb',
      }
    },
    tileAttachment: {
      maxFileSize: 3000000,
      messages: {
        acceptFileTypes: 'File type not allowed. Must be a pdf or MS word document file',
        maxFileSize: 'File is too large. Max File size 3Mb',
      }
    }
  };


  function initChooseFileDelegator(){

    $('body').on('click',  ".js-file-upload-trigger", function(event){
      event.preventDefault();
      var uploadForm = $($(this).data("target"));

      uploadForm.find('input[type=file]').click();
      return false;
    });
  }


  function disableFileUploderTrigger(){
    $('body').off('click', ".js-file-upload-trigger");
  }


  function handleAnyFileErrors(file){
    if(file.error){
      alert("Sorry unable to upload the file due to the following error: " + file.error);
    }
  }


  function initFileUploader() {

    $(".s3-uploader").each(function(){
      var form = $(this)
        , type = form.data("uploadtype")
        , config = uploadTypes[type]
        , eventPrefix = "/s3/" + type + "/upload/"
      ;
      config.replaceFileInput = true;
      config. disableImagePreview = true;

      form.fileupload(config)
      .on('fileuploadadd', function(e, data) {
        $("#file-uploader #Content-Type").val(data.files[0].type);
        Airbo.PubSub.publish(eventPrefix + "added", data);
      }).on('fileuploadprocessalways', function (e, data) {
        handleAnyFileErrors(data.files[0]);
      }).on('fileuploadprocessdone', function (e, data) {
        Airbo.PubSub.publish(eventPrefix + "processed", data);
      }).on('fileuploadprogress', function(e, data) {
        Airbo.PubSub.publish(eventPrefix + "progress", data);
      }).on('fileuploaddone', function(e, data) {
        Airbo.PubSub.publish(eventPrefix + "done", data);
      }).on('fileuploadstop', function(data) {
        Airbo.PubSub.publish(eventPrefix + "stop", data);
      }).on('fileuploadfail', function(e, data) {
        var error = "Upload failed due to the following server error: ";
        error += $(data.jqXHR.responseXML).find("Message").text();
        alert(error);
        console.log(data.files[0].name + " " + error);
      });

    })
  }

  function init(handler){
    //TODO can't remember why this is neccessary
    disableFileUploderTrigger();
    initChooseFileDelegator();
    initFileUploader();
  }

  return {
    init: init,
    initFileUploader: initFileUploader
  };

}());
