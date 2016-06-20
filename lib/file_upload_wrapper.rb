class FileUploadWrapper
  def initialize file_upload
    @file = file_upload
  end

  def extension
    @extenstion ||=File.extname(@file.original_filename)
  end

  def path
    @file.path
  end

end
