require 'rails_helper'

describe Event do

  it "fails to create with same name" do
    name = "tag-#{Time.now.to_i}"
    t = Tag.new(:name => name)
    t.save!

    t = Tag.create(:name => name)
    expect(t).not_to be_valid

    expect { t.save! }.to raise_error(ActiveRecord::RecordInvalid)
    expect {
      Tag.create!(:name => name)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "keeps hidden flag" do
    t = Tag.find_or_create_by(name: "hidden_test")
    t.update_attribute :hidden, true
    expect(t).to be_hidden
    expect(Tag.find_by(name: "hidden_test")).to be_hidden
  end

  it '#cleanup_unused_tags returns deleted tags' do
    Tag.cleanup_unused_tags(-1.seconds)
    targets = []
    targets << Tag.create!(:name => 'del1')
    targets << Tag.create!(:name => 'del2')
    deleted = Tag.cleanup_unused_tags(-1.seconds).sort_by {|t| t.id }
    expect(deleted).to eq targets

  end

end
