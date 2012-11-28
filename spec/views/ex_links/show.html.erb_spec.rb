require 'spec_helper'

describe "ex_links/show" do
  before(:each) do
    @ex_link = assign(:ex_link, stub_model(ExLink,
      :type => "Type",
      :name => "Name",
      :uri => "MyText",
      :remote_id => "Remote"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/Remote/)
  end
end
