# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register_alias "text/html", :mobile

# Hack to allow frontend server to serve Powerpoint 2007 docs
Rack::Mime::MIME_TYPES['pptx'] = "application/vnd.openxmlformats" 
