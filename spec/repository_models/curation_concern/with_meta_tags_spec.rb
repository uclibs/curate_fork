require 'spec_helper'

describe CurationConcern::WithMetaTags do
  describe '#meta_tags' do
    let(:work) do
      FactoryGirl.build(:generic_work,
        subject: "Cheese",
        creator: ["One", "Two"])
    end

    before(:each) { Curate.stub(:permanent_url_for).and_return('http://foo.com') }

    it 'returns a Hash with Strings for keys and Arrays for values' do
      expect(work.meta_tags).to be_kind_of(Hash)
      expect(work.meta_tags.keys.first).to be_kind_of(String)
      expect(work.meta_tags.values.first).to be_kind_of(Array)
    end

    it 'adds field content to the appropriate key' do
      expect(work.meta_tags['DC.Subject']).to eq(work.subject)
    end

    it 'represents repeated fields as multiple elements in an Array' do
      expect(work.meta_tags['DC.Creator'].length).to eq(2)
    end
  end
end
