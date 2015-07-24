$(function() {
  return $('#fileupload').fileupload({
    add: function(e, data) {
      var file, types;
      types = /(\.|\/)(gif|jpe?g|png)$/i;
      file = data.files[0];
      if (types.test(file.type) || types.test(file.name)) {
        //data.context = $(tmpl("template-upload", file));
        //$('#fileupload').append(data.context);
        return data.submit();
      } else {
        return alert(file.name + " is not a gif, jpeg, or png image file");
      }
    },
    progress: function(e, data) {
      var progress;
      if (data.context) {
        progress = parseInt(data.loaded / data.total * 100, 10);
        return data.context.find('.bar').css('width', progress + '%');
      }
    },
    done: function(e, data) {
      var content, domain, file, path, to;
      file = data.files[0];
      domain = $('#fileupload').attr('action');
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name);
      to = $('#fileupload').data('post');
      content = {};
      content[$('#fileupload').data('as')] = domain + path;
      $.post(to, content);
      if (data.context) {
        return data.context.remove();
      }
    },
    fail: function(e, data) {
      alert(data.files[0].name + " failed to upload.");
      console.log("Upload failed:");
      return console.log(data);
    }
  });
});
