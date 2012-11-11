require 'spec_helper'

describe Event do
  let(:valid_attrs) do 
    {
      :etag => 'etag-string',
      :summary => "Summary text at #{DateTime.now}",
      :start_datetime => DateTime.now,
      :end_datetime => DateTime.now,
      :ical_uid => 'ical-uid-string',
    }
  end

  let(:an_event) do
    Event.new valid_attrs
  end

  it "save will success with valid attributs" do
    Event.new(valid_attrs).save.should be_true
  end

  it "save will fail without summary text" do
    attrs = valid_attrs
    attrs.delete :summary
    Event.new(attrs).save.should be_false
  end

  it "save with tag str" do
    e = an_event
    e.tag_names_str = "aa/bb cc   dd//ee"
    e.tag_names.should eql %w(aa bb cc dd ee)
    e.save.should be_true
    Event.find(e.id).tag_names.should eql %w(aa bb cc dd ee)
  end

  it "saves tag relation postion" do
    e = an_event
    e.tag_names_str = "a b c d e"
    e.save
    e.tag_relations.map {|r| r.pos }.should eql (1..5).to_a
    e.tag_names = %w(m n o p)
    e.save
    e.tag_relations.map {|r| r.pos }.should eql (1..4).to_a
  end

  it "keeps tag order" do
    e = Event.new(valid_attrs)
    e.tag_names_str = "x y a b 0"
    e.save
    Event.find(e.id).tag_names.should eql %w(x y a b 0)
    e.tag_names = %w(Z ii hhh 0000)
    e.save
    Event.find(e.id).tag_names.should eql %w(Z ii hhh 0000)
  end
end
