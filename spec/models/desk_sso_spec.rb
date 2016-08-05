# FIXME: DEPRECATE not used anymore
# require 'spec_helper'
# require 'uri'
#
# describe DeskSSO, "#url" do
#   let (:user)    { FactoryGirl.build_stubbed(:user, email: 'johndoe@example.com', name: 'John Doe') }
#   let (:desksso) { DeskSSO.new(user) }
#
#   describe "#url" do
#     xit "should generate a URL for SSO with the proper query parameters" do
#       desksso.stubs(:multipass).returns("MULTIPASS")
#       desksso.stubs(:signature).returns("SIGNATURE")
#
#       url = URI.parse(desksso.url)
#       url.host.should == "airbo.desk.com"
#       url.path.should == "/customer/authentication/multipass/callback"
#       url.query.should == "multipass=MULTIPASS&signature=SIGNATURE"
#     end
#   end
#
#   describe "#multipass" do
#     after do
#       Timecop.return
#     end
#
#     xit "should return the proper value" do
#       Timecop.freeze(Time.parse("2011-05-30T12:00:00-04:00"))
#       multipass = desksso.multipass
#
#       decoded_multipass = Base64.decode64(multipass)
#       iv = decoded_multipass[0..16]
#       enciphered_multipass = decoded_multipass[16..-1]
#
#       decipher = OpenSSL::Cipher::AES.new(128, :CBC)]
#       decipher.decrypt
#       decipher.key = desksso.send(:encryption_key)
#       decipher.iv = iv
#       deciphered_multipass = decipher.update(enciphered_multipass) + decipher.final
#
#       parsed_multipass = JSON.parse(deciphered_multipass)
#
#       parsed_multipass.length.should == 4
#       parsed_multipass["uid"].should == user.id
#       parsed_multipass["expires"].should == "2011-05-30T13:00:00-04:00"
#       parsed_multipass["customer_email"].should == user.email
#       parsed_multipass["customer_name"].should == user.name
#     end
#   end
#
#   describe "#signature" do
#     xit "should return the proper value" do
#       fake_multipass = "base 64 encodeded multipass"
#       desksso.stubs(:multipass).returns(fake_multipass)
#       desksso.signature(fake_multipass).should == Base64.encode64(OpenSSL::HMAC.digest('sha1', desksso.send(:api_key), fake_multipass))
#     end
#   end
#
#   describe "#encryption_key" do
#     xit "should return a value based on the subdomain and API key" do
#       desksso.send(:encryption_key).should == Digest::SHA1.digest(desksso.send(:api_key) + desksso.send(:subdomain))[0..16]
#     end
#   end
# end
