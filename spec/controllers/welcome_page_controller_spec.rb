require 'spec_helper'

describe WelcomePageController do
  before(:each) do
    sign_in(user)
  end

  describe 'without already waiving the page' do
    let(:user) { FactoryGirl.create(:user, waived_welcome_page: false) }

    describe '#new' do
      it 'renders the page' do
        get :new
        response.status.should == 200
        expect(response).to render_template('new')
      end
    end

    describe '#create' do
      describe 'if welcome page waived' do
        let(:params) { { waive_welcome_page: '1' } }

        before(:each) do
          post :create, params
        end
        it 'redirects to landing page' do
          expect(response).to redirect_to(catalog_index_path)
        end

        it 'sets user waived_welcome_page to true' do
          user.reload
          expect(user.waived_welcome_page).to be_true
        end
      end

      describe 'if welcome page not waived' do
        before(:each) do
          post :create
        end

        it 'redirects to landing page' do
          expect(response).to redirect_to(catalog_index_path)
        end

        it 'keeps user.waived_welcome_page as false' do
          expect(user.waived_welcome_page).to be_false
        end
      end
    end
  end

  describe 'after waiving the page' do
    let(:user) { FactoryGirl.create(:user, waived_welcome_page: true) }

    describe '#new' do
      it 'renders the page' do
        get :new
        response.status.should == 200
        expect(response).to render_template('new')
      end
    end
  end
end
