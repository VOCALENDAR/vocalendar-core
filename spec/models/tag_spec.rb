require 'spec_helper'

describe Event do

  it "fails to create with same name" do
    name = "tag-#{Time.now.to_i}"
    t = Tag.new(:name => name)
    t.save!

    t = Tag.create(:name => name)
    t.should_not be_valid
    
    lambda { t.save! }.should raise_error(ActiveRecord::RecordInvalid)
    lambda {
      Tag.create!(:name => name)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "keeps hidden flag" do
    t = Tag.find_or_create_by_name("hidden_test")
    t.update_attribute :hidden, true
    t.should be_hidden
    Tag.find_by_name("hidden_test").should be_hidden
  end
end