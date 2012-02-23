require 'spec_helper'

describe "review_items/show.html.haml" do
  before(:each) do
    @review_item = assign(:review_item, stub_model(ReviewItem,
      :item_type => "Item Type",
      :item_id => 1,
      :whodunnit => "Whodunnit",
      :object => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Item Type/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Whodunnit/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
