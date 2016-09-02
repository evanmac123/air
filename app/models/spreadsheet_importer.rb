class SpreadsheetImporter

  def initialize file
    @file = file
    @rows = []
    parse
  end

  def header
    @header
  end

  def rows
    @rows
  end

  #Need to read the original file and strip put nont UTF-8 characters
  def sanitized_file
    tmpfile =  Tempfile.new(["foo", @file.extension])

    tmpfile.write(File.read(@file.path).encode('utf-8', 'binary', invalid: :replace, undef: :replace, replace: ''))
    tmpfile.rewind
    tmpfile
  end

  def spreadsheet
    @spreadsheet ||=
      if @file.extension =~ /\.csv/i
        Roo::CSV.new(sanitized_file.path, csv_options: {encoding: "UTF-8"})
      else
        Roo::Spreadsheet.open(@file.path, extension: @file.extension )
      end
  end

  def parse
    @header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[@header, spreadsheet.row(i)].transpose]
      @rows << row
    end
  end

end
