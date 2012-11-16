require 'spec_helper'

describe Unsubscribe do
  before do
    @karla = FactoryGirl.create(:user, name: 'Karla')
    @naomi = FactoryGirl.create(:user, name: 'Naomi')
    @token_karla = EmailLink.generate_token(@karla)
    @token_naomi = EmailLink.generate_token(@naomi)
  end

  it "should generate a valid token" do
    @token_karla.class.should == String
    @token_karla.length.should == 40
    EmailLink.validate_token(@karla, @token_karla).should be_true
    EmailLink.validate_token(@naomi, @token_karla).should be_false
    EmailLink.validate_token(@naomi, 'blah').should be_false
  end
end
