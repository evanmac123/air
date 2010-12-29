Then /^I should see a list of demos$/ do
  within "ul.demos" do
    page.should have_css("li a", :text => "3M")
    page.should have_css("li a", :text => "Fidelity")
    page.should have_css("li a", :text => "Mastercard")
  end
end
