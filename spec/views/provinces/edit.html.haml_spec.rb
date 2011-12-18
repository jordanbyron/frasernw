require 'spec_helper'

describe "provinces/edit.html.haml" do
  before(:each) do
    @province = assign(:province, stub_model(Province))
  end

  it "renders the edit province form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => provinces_path(@province), :method => "post" do
    end
  end
end
