require 'spec_helper'

describe Unsubscribe do
  before do
    @karla = FactoryGirl.create(:user, name: 'Karla')
    @naomi = FactoryGirl.create(:user, name: 'Naomi')
    @token_karla = Unsubscribe.generate_token(@karla)
    @token_naomi = Unsubscribe.generate_token(@naomi)
  end

  it "should generate a valid token" do
    @token_karla.class.should == String
    @token_karla.length.should == 40
    Unsubscribe.validate_token(@karla, @token_karla).should be_true
    Unsubscribe.validate_token(@naomi, @token_karla).should be_false
    Unsubscribe.validate_token(@naomi, 'blah').should be_false
  end
end
