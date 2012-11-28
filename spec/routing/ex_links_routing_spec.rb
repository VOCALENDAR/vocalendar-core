require "spec_helper"

describe ExLinksController do
  describe "routing" do

    it "routes to #index" do
      get("/ex_links").should route_to("ex_links#index")
    end

    it "routes to #new" do
      get("/ex_links/new").should route_to("ex_links#new")
    end

    it "routes to #show" do
      get("/ex_links/1").should route_to("ex_links#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ex_links/1/edit").should route_to("ex_links#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ex_links").should route_to("ex_links#create")
    end

    it "routes to #update" do
      put("/ex_links/1").should route_to("ex_links#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ex_links/1").should route_to("ex_links#destroy", :id => "1")
    end

  end
end
