require 'csv'
require 'digest/sha1'

150000.times do
  fields = [].tap do |fields|
    19.times { fields << Digest::SHA1.hexdigest(rand(100000).to_s) }
    checksum = Digest::SHA1.hexdigest(fields.join)

    puts CSV.generate_line(fields + [checksum])
  end
end

