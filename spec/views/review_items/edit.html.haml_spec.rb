require 'spec_helper'

describe "review_items/edit.html.haml" do
  before(:each) do
    @review_item = assign(:review_item, stub_model(ReviewItem,
      :item_type => "MyString",
      :item_id => 1,
      :whodunnit => "MyString",
      :object => "MyText"
    ))
  end

  it "renders the edit review_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => review_items_path(@review_item), :method => "post" do
      assert_select "input#review_item_item_type", :name => "review_item[item_type]"
      assert_select "input#review_item_item_id", :name => "review_item[item_id]"
      assert_select "input#review_item_whodunnit", :name => "review_item[whodunnit]"
      assert_select "textarea#review_item_object", :name => "review_item[object]"
    end
  end
end
