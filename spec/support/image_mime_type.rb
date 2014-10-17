def should_have_valid_mime_type(klass, field)
  good_mime_types = ["image/bmp", "image/x-windows-bmp", "image/gif", "image/jpeg", "image/pjpeg", "image/x-portable-bmp", "image/png"]
  # The last one, for Powerpoint, isn't a bad MIME type: it's the worst MIME type.
  bad_mime_types = ["text/plain", "x-vendor-initrode/foobar", "application/vnd.ms-powerpointtd"]

  good_mime_types.each do |good_mime_type|
    model_object = klass.new(field => good_mime_type)
    model_object.valid?
    model_object.errors[field].should be_empty
  end

  bad_mime_types.each do |bad_mime_type|
    model_object = klass.new(field => bad_mime_type)
    model_object.valid?
    model_object.errors[field].should include("that doesn't look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png.")
  end
end
