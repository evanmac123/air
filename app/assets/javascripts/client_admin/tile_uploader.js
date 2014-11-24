function bindTileUploader() {
  $( document ).ready(function() {
    window.MAX_IMAGE_CREDIT_LENGTH = 50;
    saveImageCreditChanges();
    truncateImageCreditView();
  });

  function showPlaceholder() {
    $(".image_preview").removeClass("show_shadows").addClass("show_placeholder");
  };

  function showShadows() {
    $(".image_preview").removeClass("show_placeholder").addClass("show_shadows");
  };

  var imageFileTypes = [
    "image/bmp",
    "image/x-windows-bmp",
    "image/gif",
    "image/jpeg",
    "image/pjpeg",
    "image/x-portable-bmp",
    "image/png"
  ];

  function filetypeNotOnWhitelist(file) {
    var type = file.type;
    return ($.inArray(type, imageFileTypes) == -1);
  };

  $("#tile_builder_form_image").change(function PreviewImage(event) {
    var attachedFile = document.getElementById("tile_builder_form_image").files[0];
    if(filetypeNotOnWhitelist(attachedFile)) {
      alert("Sorry, that doesn't look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png.");
      event.preventDefault();
      return(false);
    }

    var oFReader = new FileReader();
    oFReader.readAsDataURL(attachedFile);

    oFReader.onload = function (oFREvent) {
      document.getElementById("upload_preview").src = oFREvent.target.result;
    };
    $("#image_container").val("");
    showShadows();
  });

  $(".clear_image").click(function clearImage(event) {
    event.preventDefault();
    $("#image_container").val("no_image");
    var control = $("#tile_builder_form_image");
    control.replaceWith( control = control.clone( true ) );
    showPlaceholder();
    // remove image credit
    $(".image_credit_view").text("");
    saveImageCreditChanges();
  });

  $(".image_credit_view").keyup( function(){ 
    saveImageCreditChanges("keyup");
    truncateImageCreditView();    
  });

  $(".image_credit_view").keydown( function deleteTruncateImageCredit(e){ 
    div_input = $(this);
    if( div_input.hasClass("truncate") && e.keyCode == 8 ){//backspace
      div_input.removeClass("truncate");
      div_input.text("");
    }
  });

  $(".image_credit_view").click(function deleteImageCreditPlaceholder(){
    if( $(this).hasClass("empty")){
      $(this).text("").focus();
    }
  });

  $(".image_credit_view").focusout(function addImageCreditPlaceholder(){
    if( $(this).hasClass("empty")){
      $(this).text("Add Image Credit");
    }
  });

  $(".image_credit_view").bind("paste", function(){
    $(".image_credit_view").text("").addClass("remove").removeClass("truncate");
  });

  function saveImageCreditChanges(caller) {
    div_input = $(".image_credit_view");
    //check if we have any text in div(delete spaces)
    text_length = div_input.text().replace(/\s+/g, '').length

    if(text_length == 0){
      div_input.addClass("empty").removeClass("truncate");
      if (!div_input.is(":focus") && caller != "keyup") {
        div_input.text("Add Image Credit")
      }
      text = "";
    }else if( div_input.hasClass("truncate") ){
      text = $("#tile_builder_form_image_credit").text(); //do nothing
    }else if(text_length > 0){
      div_input.removeClass("empty")
      text = div_input.text();
    }
    $("#tile_builder_form_image_credit").text(text);
  };

  function truncateImageCreditView(){
    div_input = $(".image_credit_view");
    text = div_input.text();
    if( !div_input.hasClass("truncate") && text.length > MAX_IMAGE_CREDIT_LENGTH + 3){
      div_input.text(div_input.text().substring(0,50) + "...");
      div_input.addClass("truncate");
    }
  };
}

function bindTileUploaderIE() {
  $( document ).ready(function() {
    saveImageCreditChanges();
    addCharacterCounterFor('#tile_builder_form_image_credit');
  });

  function saveImageCreditChanges() {
    input = $("#tile_builder_form_image_credit");
    if(input.val() != ""){
      if(input.val().length > 50 ){
        text = input.val().substring(0,50) + "...";
      }else{
        text = input.val();
      }
    }else{
      text = "Add Image Credit"
    }
    $(".image_credit_view").html(text);
  };

  $("#tile_builder_form_image_credit").bind('input propertychange', function(){ 
    saveImageCreditChanges();     
  });
}
