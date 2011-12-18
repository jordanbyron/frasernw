require 'spec_helper'

describe "provinces/index.html.haml" do
  before(:each) do
    assign(:provinces, [
      stub_model(Province),
      stub_model(Province)
    ])
  end

  it "renders a list of provinces" do
    render
  end
end
