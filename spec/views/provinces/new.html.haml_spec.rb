require 'spec_helper'

describe "provinces/new.html.haml" do
  before(:each) do
    assign(:province, stub_model(Province).as_new_record)
  end

  it "renders new province form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => provinces_path, :method => "post" do
    end
  end
end
