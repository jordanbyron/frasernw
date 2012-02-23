require "spec_helper"

describe ReviewItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/review_items").should route_to("review_items#index")
    end

    it "routes to #new" do
      get("/review_items/new").should route_to("review_items#new")
    end

    it "routes to #show" do
      get("/review_items/1").should route_to("review_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/review_items/1/edit").should route_to("review_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/review_items").should route_to("review_items#create")
    end

    it "routes to #update" do
      put("/review_items/1").should route_to("review_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/review_items/1").should route_to("review_items#destroy", :id => "1")
    end

  end
end
