require 'spec_helper'

describe "ex_links/index" do
  before(:each) do
    assign(:ex_links, [
      stub_model(ExLink,
        :type => "Type",
        :name => "Name",
        :uri => "MyText",
        :remote_id => "Remote"
      ),
      stub_model(ExLink,
        :type => "Type",
        :name => "Name",
        :uri => "MyText",
        :remote_id => "Remote"
      )
    ])
  end

  it "renders a list of ex_links" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Remote".to_s, :count => 2
  end
end
