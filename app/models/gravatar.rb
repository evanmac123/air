require 'digest/md5'

class Gravatar
  def initialize(email)
    @email = email.downcase
  end

  def url(size)
    hash = Digest::MD5.hexdigest(@email)
    "http://gravatar.com/avatar/#{hash}?s=#{size}"
  end
end
