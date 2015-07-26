$(function() {

    function imagePreview(data){
      var node, imagePlaceholder, index = data.index ||0, file = data.files[index];

      data.context = $(".img-area");
      imagePlaceholder =data.context.find(".image-placeholder"); 
      node = data.context.find(".preview");
      if (file.preview) {
        //Built-in image preview (scales images)
        node.prepend('<br>').html(file.preview);
      }else{
        //Manual image preview (no scaling)
        //imagePlaceholder.hide();

        loadImage( file, function (img) { 
          node.html(img);
        },{canvas: true} );
      }

      if (file.error) {
        node
        .append('<br>')
        .append($('<span class="text-danger"/>').text(file.error));
      }
      //if (index + 1 === data.files.length) {
        //data.context.find('button.upload')
        //.text('Upload')
        //.prop('disabled', !!data.files.error);
      //}
    }


  function initChooseFileDelegator(){
    uploadForm= $("#fileupload");
    $('body').on('click', "#clickDelegator", function(event){
      event.preventDefault();
      uploadForm.find('input[type=file]').click();
      return false;
    });
  }

  setPreviewImage = function(imageUrl) {
    return document.getElementById('upload_preview').src = imageUrl;
  };

  isIE = function() {
    var myNav;
    myNav = navigator.userAgent.toLowerCase();
    if (myNav.indexOf('msie') !== -1) {
      return parseInt(myNav.split('msie')[1]);
    } else {
      return false;
    }
  };

  getAttachedFile = function() {
    return document.getElementById("media_file").files[0];
  };

  //showImgInPreview = function(file) {
   //$(".image_preview").append(file.preview);
   ////showShadows();
  //};

  showImgInPreview = function(imgFile) {
    var oFReader;
    oFReader = new FileReader;
    oFReader.readAsDataURL(imgFile);
    return oFReader.onload = function(oFREvent) {
      return setPreviewImage(oFREvent.target.result);
    };
  };

showShadows = function() {
    return $('.image_preview').removeClass('show_placeholder').addClass('show_shadows');
  };

   $('#fileupload').fileupload({
     replaceFileInput: false
   }).on('fileuploadadd',  function(e, data) {
      var file, types;
      types = /(\.|\/)(gif|jpe?g|png)$/i;
      file = data.files[0];
      if (types.test(file.type) || types.test(file.name)) {
        return data.submit();
      } else {
        return alert(file.name + " is not a gif, jpeg, or png image file");
      }
    }).on('fileuploadprocessalways',  function (e, data) {
      attachedFile = $("#media_file")[0].files[0];
      showImgInPreview(attachedFile);
      showShadows();
      //imagePreview(data);
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
      to = $('#fileupload').data('post');
      content = {};
      content[$('#fileupload').data('as')] = domain + path;
      //$.post(to, content);
      //if (data.context) {
        //return data.context.remove();
      //}
    }).on('fileuploadfail',  function(e, data) {
      alert(data.files[0].name + " failed to upload.");
      console.log("Upload failed:");
      return console.log(data);
    });
});
