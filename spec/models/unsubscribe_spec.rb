require 'spec_helper'

describe Unsubscribe do
  before do
    @karla = FactoryGirl.create(:user, name: 'Karla')
    @naomi = FactoryGirl.create(:user, name: 'Naomi')
    @token_karla = EmailLink.generate_token(@karla)
    @token_naomi = EmailLink.generate_token(@naomi)
  end

  it "should generate a valid token" do
    expect(@token_karla.class).to eq(String)
    expect(@token_karla.length).to eq(40)
    expect(EmailLink.validate_token(@karla, @token_karla)).to be_truthy
    expect(EmailLink.validate_token(@naomi, @token_karla)).to be_falsey
    expect(EmailLink.validate_token(@naomi, 'blah')).to be_falsey
  end
end
