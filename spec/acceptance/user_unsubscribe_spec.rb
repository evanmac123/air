require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Leah unsubscribes" do
  before(:each) do
    Unsubscribe.delete_all
    @leah = FactoryGirl.create(:user, name: 'Leah Eckles')
    @token = Unsubscribe.generate_token(@leah)
    @unsubscribe_url = new_unsubscribe_path({user_id: @leah.id, token: @token})
    @reason = "I'm just having way too much fun on YouTube"
  end

  it "should have a link at the bottom of the email that points to the unsubscribe page" do
    email = Mailer.easy_in(@leah)
    [email.html_part.body, email.text_part.body].each do |body|
      body.should include @unsubscribe_url.gsub("&", "&amp;")
    end
  end

  it "should create an unsubscribe" do
    Unsubscribe.count.should == 0
    visit @unsubscribe_url
    fill_in 'unsubscribe_reason', with: @reason 
    click_button 'Completely Unsubscribe'
    page.should have_content 'You have been unsubscribed'
    Unsubscribe.count.should == 1
    a = Unsubscribe.first
    a.user_id.should == @leah.id
    a.reason.should == @reason
  end
end


