require "spec_helper"

describe TileBuilderForm do
  let!(:demo) { FactoryGirl.create(:demo) }
  let!(:user) { FactoryGirl.create(:client_admin) }
  let!(:options) do
    {
      parameters: {
        headline: "Head",
        supporting_content: "Support",
        question: "Points for taking action",
        link_address: "",
        question_type: Tile::ACTION,
        question_subtype: Tile::TAKE_ACTION,
        image_credit: nil,
        points: "10",
        correct_answer_index: -1,
        answers: ["I did it"],
        image: File.open(Rails.root.join "spec/support/fixtures/tiles/cov1.jpg")
      },
      creator: user
    }
  end



  context "sanitize formatting in supporting content" do
    it "should allow: 'ul', 'ol', 'li', 'b', 'i', 'u', 'span', 'br', 'a', 'div'" do
      options[:parameters][:supporting_content] = <<HTML
The <b>origin</b> of the <a href="/wiki/Dog" target="_blank">domestic dog</a>
<i>(Canis lupus familiaris or Canis familiaris)</i> is not clear.
<br>
Few devisions:
<ul>
  <li>The wolf-like canids</li>
  <li>The fox-like canids</li>
  <li>The South American canids</li>
</ul>
HTML
      options[:parameters][:supporting_content].strip!
      form = TileBuilderForm.new(demo, options)
      form.create_tile.should be_true
      form.tile.supporting_content.should == options[:parameters][:supporting_content]
    end

    it "should not allow other tags or attributes" do
      options[:parameters][:supporting_content] = <<HTML
<scipt>alert("Hello! My name is Lindsey Lohan")</script>
HTML
      options[:parameters][:supporting_content].strip!
      form = TileBuilderForm.new(demo, options)
      form.create_tile.should be_true
      form.tile.supporting_content.should == "alert(\"Hello! My name is Lindsey Lohan\")"

      options[:parameters][:supporting_content] = <<HTML
<html>
HTML
      options[:parameters][:supporting_content].strip!
      form = TileBuilderForm.new(demo, options)
      form.create_tile.should be_false
      form.error_messages.should == "supporting content can't be blank."
      form.tile.supporting_content.should == ""

      options[:parameters][:supporting_content] = <<HTML
<div id="id1" class="class2" style="color:red;">
Text
</div>
HTML
      options[:parameters][:supporting_content].strip!
      form = TileBuilderForm.new(demo, options)
      form.create_tile.should be_true
      form.tile.supporting_content.should == "<div>\nText\n</div>"
    end
  end
end