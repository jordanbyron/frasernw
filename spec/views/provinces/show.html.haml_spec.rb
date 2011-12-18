require 'spec_helper'

describe "provinces/show.html.haml" do
  before(:each) do
    @province = assign(:province, stub_model(Province))
  end

  it "renders attributes in <p>" do
    render
  end
end
