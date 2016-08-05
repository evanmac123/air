# FIXME: DEPRECATE not used anymore
class DeskSSO
  def initialize(user)
    @user = user
  end

  def url
    _multipass = multipass
    _signature = signature(_multipass)

    "https://#{subdomain}.desk.com/customer/authentication/multipass/callback?multipass=#{CGI.escape(_multipass)}&signature=#{CGI.escape(_signature)}"
  end

  def multipass
    Base64.encode64(encrypt(user_json))
  end

  def signature(_multipass)
    Base64.encode64(OpenSSL::HMAC.digest('sha1', api_key, _multipass))
  end

  private

  def user_json
    user_data.to_json
  end

  def user_data
    {
      "uid"            => @user.id,
      "expires"        => (Time.now + 1.hour).iso8601,
      "customer_email" => @user.email,
      "customer_name"  => @user.name
    }
  end

  def encrypt(text)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = encryption_key
    iv = cipher.random_iv
    cipher.iv = iv

    encrypted = cipher.update(text) + cipher.final

    iv + encrypted
  end

  def encryption_key
    Digest::SHA1.digest(api_key + subdomain)[0..16]
  end

  def subdomain
    "airbo"
  end

  def api_key
    ENV['DESK_API_KEY'] || "test desk site key must be long enough for encryption key"
  end
end
