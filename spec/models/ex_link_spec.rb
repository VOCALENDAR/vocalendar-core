require 'spec_helper'

describe ExLink do
  def valid_attrs
    {
      uri: "http://vocalendar.jp/#{Time.now.to_f}"
    }
  end

  def a_link
    ExLink.new(valid_attrs)
  end

  it "creates digest from URI" do
    l1 = a_link
    l1.save!
    l1.should be_digest
    l1.digest.should_not be_empty
    l2 = a_link
    l2.save!
    l2.hash.should_not eq l1.hash
  end

  it "scans URL from text" do
    links = ExLink.scan("hoge hoge http://test.com/#abc\n and 2nd URL is (http://vocalendar.jp/).")
    links.should have(2).items
  end

end
