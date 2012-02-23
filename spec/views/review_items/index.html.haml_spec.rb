require 'spec_helper'

describe "review_items/index.html.haml" do
  before(:each) do
    assign(:review_items, [
      stub_model(ReviewItem,
        :item_type => "Item Type",
        :item_id => 1,
        :whodunnit => "Whodunnit",
        :object => "MyText"
      ),
      stub_model(ReviewItem,
        :item_type => "Item Type",
        :item_id => 1,
        :whodunnit => "Whodunnit",
        :object => "MyText"
      )
    ])
  end

  it "renders a list of review_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Item Type".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Whodunnit".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
