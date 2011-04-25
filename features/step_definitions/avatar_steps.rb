When /^I attach the avatar "(.*?)"$/ do |filename|
  path = Rails.root.join('features/support/fixtures/avatars', filename)
  attach_file "user[avatar]", path
end

Then /^I should see an avatar "(.*?)" for "(.*?)"$/ do |filename, username|
  user = User.find_by_name(username)

  expected_image_url = [
    'http://s3.amazonaws.com',
    S3_AVATAR_BUCKET,
    'avatars',
    user.id,
    filename
  ].join('/')

  page.should have_css("img[src^='#{expected_image_url}']")
end

Then /^I should see the default avatar for "(.*?)"$/ do |username|
  page.should have_css("img[src^='/avatars/original/missing.png']")
end
