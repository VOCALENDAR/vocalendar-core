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
    expect(l1).to be_digest
    expect(l1.digest).not_to be_empty
    l2 = a_link
    l2.save!
    expect(l2.hash).not_to eq l1.hash
  end

  it "scans URL from text" do
    links = ExLink.scan("hoge hoge http://test.com/#abc\n and 2nd URL is (http://vocalendar.jp/).")
    expect(links.size).to eq(2)
  end

  it "cannot set uri when it has been saved" do
    l = a_link
    l.save!
    l.title = "hoge"
    expect(l.save).to be_true
    expect {
      l.uri = "http://www.nicovideo.jp"
    }.to raise_error(ArgumentError)
  end

end
