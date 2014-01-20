desc "Convert a LyX file into an html table of contents and linking page using eLyXer"
task :lyx do
  command = 'python lib/elyxer/elyxer.py --nofooter --notoclabels --raw '
  raw_file = ' app/views/pages/raw_faq/faq.lyx '
  html_body = 'app/views/pages/_faq_body.html.erb'
  html_body_as_seen_by_toc_no_erb = 'app/views/pages/_faq_body.html'
  html_toc = 'app/views/pages/_faq_toc.html'  # this one has no space around it so we can read and write files to it
  body_created = system(command + raw_file + ' ' + html_body)
  toc_options = " --tocfor #{html_body_as_seen_by_toc_no_erb} "
  toc_created  = system(command + toc_options + raw_file + ' ' + html_toc)
  raise "Unable to create body and toc .html from .lyx file" unless body_created && toc_created
  
  # These next three lines can be used to open the generated file, make some substitutions, and save it again
  toc = IO.read(html_toc)  # You could replace the label 'subsection' here, but we decided to go with elyxer's --notoclabels flag 
  toc = toc.gsub('app/views/pages/_faq_body.html', '')  #remove the link prepend so links work in-place
  File.open(html_toc, 'w') {|f| f.write(toc) }

  ######################   SUBSTITUTIONS   ####################
  body = IO.read(html_body)  # You could replace the label 'subsection' here, but we decided to go with elyxer's --notoclabels flag 
  # Make support email be an actual hyperlink
  body = body.gsub('support@air.bo', "<a href='#' class='contact_us_link'>support@air.bo</a>")
  # Insert Game Phone Number and Game Email
  body = body.gsub('&lt;GAME_PHONE&gt;', '<%= @current_user.demo.phone_number.try(:as_pretty_phone) %>')
  body = body.gsub('&lt;GAME_EMAIL&gt;', "<a href='mailto:<%= @current_user.demo.email %>'><%= @current_user.demo.email %></a>")
  
  File.open(html_body, 'w') {|f| f.write(body) }
  
  puts "F.A.Q. generated"
end
