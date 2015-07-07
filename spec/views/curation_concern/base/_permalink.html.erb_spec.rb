require 'spec_helper'

describe 'curation_concern/base/_permalink.html.erb' do
  let(:curation_concern) { stub_model(GenericWork, pid: 'sufia:1234', noid: '1234') }
  let(:path) { common_object_path(curation_concern.noid) }
  let(:link) { I18n.t('sufia.application_uri') + path }

  before do
    render partial: 'permalink', locals: { curation_concern: curation_concern }
  end

  it 'it should display the link' do
    expect(rendered).to have_link(link, link)
  end
end
