require 'spec_helper'

describe 'meta tags' do
  describe 'dublin core' do
    before(:all) do
      generic_work = FactoryGirl.create(:public_generic_work,
        identifier: 'doi:foo1bar2')
      visit curation_concern_generic_work_path(generic_work)
    end

    it 'displays identifier' do
      tag_label = 'dc.identifier'
      tag_value = 'doi:foo1bar2'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"

      expect(page).to have_css(tag, visible: false)
    end
  end
end
