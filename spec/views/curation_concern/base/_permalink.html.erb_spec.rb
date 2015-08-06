require 'spec_helper'

describe 'curation_concern/base/_permalink.html.erb' do
  let(:curation_concern) { stub_model(GenericWork, pid: 'sufia:1234', noid: '1234') }
  let(:link) { Curate.permanent_url_for(curation_concern) }

  before do
    render partial: 'permalink', locals: { curation_concern: curation_concern }
  end

  it 'it should display the link' do
    expect(rendered).to have_link(link, link)
  end
end
