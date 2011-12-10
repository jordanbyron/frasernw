require "spec_helper"

describe HealthcareProvidersController do
  describe "routing" do

    it "routes to #index" do
      get("/healthcare_providers").should route_to("healthcare_providers#index")
    end

    it "routes to #new" do
      get("/healthcare_providers/new").should route_to("healthcare_providers#new")
    end

    it "routes to #show" do
      get("/healthcare_providers/1").should route_to("healthcare_providers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/healthcare_providers/1/edit").should route_to("healthcare_providers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/healthcare_providers").should route_to("healthcare_providers#create")
    end

    it "routes to #update" do
      put("/healthcare_providers/1").should route_to("healthcare_providers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/healthcare_providers/1").should route_to("healthcare_providers#destroy", :id => "1")
    end

  end
end
