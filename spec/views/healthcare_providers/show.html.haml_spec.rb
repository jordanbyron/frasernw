require 'spec_helper'

describe "healthcare_providers/show.html.haml" do
  before(:each) do
    @healthcare_provider = assign(:healthcare_provider, stub_model(HealthcareProvider,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
