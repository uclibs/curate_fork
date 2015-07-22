require 'spec_helper'

describe 'registrations/edit' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  before do
    view.stub(:current_user).and_return(user)
    view.stub(:resource).and_return(user)
    view.stub(:resource_name).and_return(user)
    view.stub(:devise_mapping).and_return(Devise.mappings[:user])
    render
  end

  it 'displays password fields with autocomplete turned off' do
    expect(rendered).to have_tag('input[autocomplete=off]', count: 3)
  end
end
