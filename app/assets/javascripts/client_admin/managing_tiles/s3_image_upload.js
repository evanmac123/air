var Airbo = window.Airbo || {}
Airbo.DirectToS3ImageUploader = (function(){ 

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
        setPreviewImage(img.toDataURL());
        showShadows();
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

  function setPreviewImage(imageUrl) {
    $('#upload_preview').attr("src", imageUrl);
  };

  function showShadows() {
    return $('.image_preview').removeClass('show_placeholder').addClass('show_shadows');
  };


  function initFileUploader() {

    $('#fileupload').fileupload(
      {
        replaceFileInput: false,
        disableImagePreview: true
      }
    ).on('fileuploadadd',  function(e, data) {
      var file = data.files[0],
          types = /(\.|\/)(gif|jpe?g|png|bmp)$/i;

        if (types.test(file.type) || types.test(file.name)) {
          return data.submit();
        } else {
          return alert(file.name + " is not a gif, jpeg, or png image file");
        }

    }).on('fileuploadprocessalways',  function (e, data) {
      imagePreview(data);
    }).on('fileuploadprogress', function(e, data) {
      var progress;
      if (data.context) {
        progress = parseInt(data.loaded / data.total * 100, 10);
        return data.context.find('.bar').css('width', progress + '%');
      }
    }).on('fileuploaddone', function(e, data) {
      var content, domain, file, path, to;
      file = data.files[0];
      domain = $('#fileupload').attr('action');
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name);
      debugger
      //$.post(to, content);
      //if (data.context) {
      //return data.context.remove();
      //}
    }).on('fileuploadfail',  function(e, data) {
      console.log(data.files[0].name + " failed to upload.");
    });
  }

  function init(){
    initChooseFileDelegator();
    initFileUploader();
  }

  return {
    init: init
  };

}());

$(function() {
Airbo.DirectToS3ImageUploader.init();
});
