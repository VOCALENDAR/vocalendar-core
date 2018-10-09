require "spec_helper"

describe HistoriesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/manage/histories")).to route_to("histories#index")
    end

  end
end
