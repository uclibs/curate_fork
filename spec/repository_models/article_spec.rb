require 'spec_helper'

describe Article do

  subject { Article.new }

  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_common_solr_fields'

  it { should have_unique_field(:abstract) }
  it { should have_multivalue_field(:alternate_title) }
  it { should have_unique_field(:bibliographic_citation) }
  it { should have_multivalue_field(:contributor) }
  it { should have_multivalue_field(:coverage_spatial) }
  it { should have_multivalue_field(:coverage_temporal) }
  it { should have_multivalue_field(:creator) }
  it { should have_unique_field(:date_created) }
  it { should have_unique_field(:date_modified) }
  it { should have_unique_field(:date_uploaded) }
  it { should have_unique_field(:identifier) }
  it { should have_unique_field(:issn) }
  it { should have_unique_field(:journal_title) }
  it { should have_multivalue_field(:language) }
  it { should have_unique_field(:note) }
  it { should have_unique_field(:publisher) }
  it { should have_unique_field(:publisher_digital) }
  it { should have_unique_field(:requires) }
  it { should have_unique_field(:rights) }
  it { should have_multivalue_field(:subject) }
  it { should have_unique_field(:title) }

  it { should have_unique_field(:human_readable_type) }

  describe 'to_solr' do
    it 'derives dates from date_created fields' do
      date_string = '2010-4-5'
      art = FactoryGirl.build(:article, date_created: date_string)
      solr_doc = art.to_solr
      solr_doc['desc_metadata__date_created_tesim'].should == [date_string]
      expected_date = Date.parse(date_string)
      solr_doc['date_created_derived_dtsim'].first.to_date.should == expected_date
    end
  end

  describe 'related_works' do
    subject { FactoryGirl.create(
      :article,
      title: 'One Scholarly Paper',
      abstract:'This paper is really important. That is why I put it in the repository.'
    )}

    it_behaves_like 'with_related_works'
  end
end
