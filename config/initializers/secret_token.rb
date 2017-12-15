# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

if Rails.env.production?
  Health::Application.config.secret_key_base = ENV['SECRET_TOKEN']
else
  Health::Application.config.secret_key_base = '22f4dd8f651d565909b6a80c465eb8e102ac3938e3b2cec138329ee784ce963fe94dc87c5f4c72e22a21d3d96bab1c5a7cbd393f56340731ba46258c74bbd6b5'
end
