require "spec_helper"

describe HistoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/manage/histories").should route_to("histories#index")
    end

  end
end
