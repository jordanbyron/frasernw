require 'spec_helper'

describe "review_items/new.html.haml" do
  before(:each) do
    assign(:review_item, stub_model(ReviewItem,
      :item_type => "MyString",
      :item_id => 1,
      :whodunnit => "MyString",
      :object => "MyText"
    ).as_new_record)
  end

  it "renders new review_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => review_items_path, :method => "post" do
      assert_select "input#review_item_item_type", :name => "review_item[item_type]"
      assert_select "input#review_item_item_id", :name => "review_item[item_id]"
      assert_select "input#review_item_whodunnit", :name => "review_item[whodunnit]"
      assert_select "textarea#review_item_object", :name => "review_item[object]"
    end
  end
end
