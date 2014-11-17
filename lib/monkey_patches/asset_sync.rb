module AssetSync
  class MultiMime
    def self.lookup(ext)
      _ext = ext =~ /\.gz$/ ? ext.gsub(/\.gz$/, '') : ext

      Mime::Type.lookup_by_extension(_ext)
    end
  end
end

