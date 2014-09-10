require 'spec_helper'

describe HelpRequestsController do
  describe 'GET #new' do
    let(:user) { FactoryGirl.create(:user) }
    it 'is allowed when not logged in' do
      get(:new)
      expect(response.status).to eq(200)
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:attributes) { {} }
    describe 'success' do
      let(:attributes) { FactoryGirl.attributes_for(:help_request) }
      it 'redirects to dashboard and flashes a message' do
        sign_in(user)
        post(:create, help_request: attributes)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(catalog_index_path)
      end
    end
    describe 'failure' do
      let(:attributes) { FactoryGirl.attributes_for(:help_request_invalid) }
      it 're-renders the form' do
        sign_in(user)
        post(:create, help_request: attributes)
        expect(response.status).to eq(200)
        expect(response).to render_template('new')
      end
    end
  end
end
