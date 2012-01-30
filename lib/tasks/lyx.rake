desc "Convert a LyX file into an html table of contents and linking page using eLyXer"
task :lyx do
  command = 'python lib/elyxer/elyxer.py --nofooter --raw '
  raw_file = ' app/views/pages/raw_faq/faq.lyx '
  html_body = ' app/views/pages/_faq_body.html '
  html_toc = 'app/views/pages/_faq_toc.html'  # this one has no space around it so we can read and write files to it
  body_created = system(command + raw_file + html_body)
  toc_options = " --tocfor #{html_body} "
  toc_created  = system(command + toc_options + raw_file + html_toc)
  raise "Unable to create html from .lyx file" unless body_created && toc_created
  # puts 'executing: "' + command + raw_file + html_body + '"'
  # puts "Generated two pages of html--a body and a table of contents--using a LyX file and the eLyXer parser"
  filtered = IO.read(html_toc).gsub('Subsection:', 'Q:')  # replace the label 'subsection'. (alternately, call elyxer with --notoclabels flag )
  filtered = filtered.gsub('app/views/pages/_faq_body.html', '')  #remove the link prepend so links work in-place
  File.open(html_toc, 'w') {|f| f.write(filtered) }
  puts "F.A.Q. generated"
end
