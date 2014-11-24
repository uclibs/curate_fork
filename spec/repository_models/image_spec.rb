require 'spec_helper'

describe Image do
  subject { Image.new }

  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_common_solr_fields'

  it { should have_unique_field(:title) }
  it { should have_unique_field(:date_uploaded) }
  it { should have_unique_field(:date_modified) }
  it { should have_unique_field(:date_photographed) }
  it { should have_unique_field(:identifier) }
  it { should have_unique_field(:rights) }
  it { should have_unique_field(:requires) }
  it { should have_unique_field(:publisher_digital) }
  it { should have_unique_field(:publisher) }
  it { should have_unique_field(:note) }
  it { should have_unique_field(:bibliographic_citation) }
  it { should have_unique_field(:inscription) }
  it { should have_unique_field(:description) }
  it { should have_unique_field(:date_created) }
  it { should have_unique_field(:type) }

  it { should have_multivalue_field(:genre) }
  it { should have_multivalue_field(:alternate_title) }
  it { should have_multivalue_field(:location) }
  it { should have_multivalue_field(:measurements) }
  it { should have_multivalue_field(:material) }
  it { should have_multivalue_field(:source) }
  it { should have_multivalue_field(:cultural_context) }

  it { should have_multivalue_field(:creator) }
  it { should have_multivalue_field(:contributor) }
  it { should have_multivalue_field(:subject) }
  it { should have_multivalue_field(:coverage_spatial) }
  it { should have_multivalue_field(:coverage_temporal) }

  describe 'to_solr' do
    it 'derives dates from date_created fields' do
      dates = ['2012-10-31', '3rd century BCE']
      image = FactoryGirl.create(:image, date_created: dates)
      solr_doc = image.to_solr

      solr_doc['desc_metadata__date_created_tesim'].length.should == 2
      solr_doc['desc_metadata__date_created_tesim'].should =~ dates

      solr_doc['date_created_derived_dtsim'].length.should == 1
      expected_date = Date.parse('2012-10-31')
      solr_doc['date_created_derived_dtsim'].first.to_date.should == expected_date
    end
  end
end
