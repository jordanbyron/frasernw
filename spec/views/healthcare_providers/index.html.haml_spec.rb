require 'spec_helper'

describe "healthcare_providers/index.html.haml" do
  before(:each) do
    assign(:healthcare_providers, [
      stub_model(HealthcareProvider,
        :name => "Name"
      ),
      stub_model(HealthcareProvider,
        :name => "Name"
      )
    ])
  end

  it "renders a list of healthcare_providers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
