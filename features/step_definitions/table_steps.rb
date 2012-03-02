Then /^I should see the following table:$/ do |table|
  # This is a step written by Jack to test that a table of 
  # data is exactly as you think it should be. 
  raw_table = table.raw
  header_row = raw_table.shift
  bit = "<table><tr>"
  header_row.each do |item|
    line = "<th>" + item + "</th>"
    bit += line
  end
  bit += "</tr>"
  raw_table.each do |row|
    bit += "<tr>"
    row.each do |cell_contents|
      line = "<td>" + cell_contents + "</td>"
      bit += line
    end
    bit += "</tr>"
  end
  bit += "</table>"
  amended = page.body
  # remove any line breaks
  amended = amended.gsub("\n", "")
  # remove any class declarations
  amended = amended.gsub(/<table.*?>/, "<table>")
  amended = amended.gsub(/<tr.*?>/, "<tr>")
  amended = amended.gsub(/<td.*?>/, "<td>")
  # remove any divs that occur in the page (especially ones that occur within the table)
  amended = amended.gsub(/<div.*?<\/div>/, "")
  amended.should include(bit)
end


