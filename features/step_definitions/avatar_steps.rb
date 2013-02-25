def expected_avatar_url(user, filename)
  [
    'https://s3.amazonaws.com',
    S3_AVATAR_BUCKET,
    'avatars',
    user.id,
    'thumb',
    filename
  ].join('/')
end

Given /^"(.*?)" has no avatar$/ do |username|
  user = User.find_by_name(username)
  user.avatar_file_name = user.avatar_content_type = user.avatar_file_size = user.avatar_updated_at = nil
  user.save!
end

When /^I attach the avatar "(.*?)"$/ do |filename|
  path = Rails.root.join('features/support/fixtures/avatars', filename)
  attach_file "user[avatar]", path
end

When /^I press the avatar submit button$/ do
  page.find(:css, ".set-avatar input[@type=submit]").click
end

When /^I press the avatar clear button$/ do
  page.find(:css, ".clear-avatar input[@type=submit]").click
end

Then /^I should( not)? see an avatar "(.*?)" for "(.*?)"$/ do |sense, filename, username|
  sense = !sense
  user = User.find_by_name(username)

  expected_img_src = expected_avatar_url(user, filename)

  if sense
    page.should have_css("img[src^='#{expected_img_src}']")
  else
    page.should have_no_css("img[src^='#{expected_img_src}']")
  end
end

Then /^I should see the default avatar for "(.*?)"$/ do |username|
  page.should have_css("img[src^='/assets/avatars/thumb/missing.png']")
end
