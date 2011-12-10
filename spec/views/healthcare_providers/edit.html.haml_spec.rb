require 'spec_helper'

describe "healthcare_providers/edit.html.haml" do
  before(:each) do
    @healthcare_provider = assign(:healthcare_provider, stub_model(HealthcareProvider,
      :name => "MyString"
    ))
  end

  it "renders the edit healthcare_provider form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => healthcare_providers_path(@healthcare_provider), :method => "post" do
      assert_select "input#healthcare_provider_name", :name => "healthcare_provider[name]"
    end
  end
end
