require 'spec_helper'

describe "ex_links/new" do
  before(:each) do
    assign(:ex_link, stub_model(ExLink,
      :type => "",
      :name => "MyString",
      :uri => "MyText",
      :remote_id => "MyString"
    ).as_new_record)
  end

  it "renders new ex_link form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => ex_links_path, :method => "post" do
      assert_select "input#ex_link_type", :name => "ex_link[type]"
      assert_select "input#ex_link_name", :name => "ex_link[name]"
      assert_select "textarea#ex_link_uri", :name => "ex_link[uri]"
      assert_select "input#ex_link_remote_id", :name => "ex_link[remote_id]"
    end
  end
end
