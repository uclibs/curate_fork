require 'spec_helper'

describe 'Profile for a Person: ' do

  context 'logged in user' do
    let(:password) { FactoryGirl.attributes_for(:user).fetch(:password) }
    let(:account) { FactoryGirl.create(:account, name: 'Iron Man') }
    let(:user) { account.user }
    let(:person) { account.person }
    before { login_as(user) }

    # TODO: confirm the intent of this test
    it 'will see a link to their profile in the nav' do
      visit catalog_index_path
      page.should have_link("My Profile", href: user_profile_path)
    end

    it 'should see their name in the edit view' do
      visit catalog_index_path
      click_link 'My Profile'
      click_link 'Update Personal Information'
      expect(page).to have_field('Name', with: 'Iron Man')
    end

    it 'should update their name and see the updated value' do
      visit catalog_index_path
      click_link 'My Profile'
      click_link 'Update Personal Information'
      page.should have_link("Cancel", href: person_path(person))
      within('form.edit_user') do
        fill_in("user[name]", with: 'Spider Man')
        fill_in("user[current_password]", with: password)
        click_button "Update Account"
      end

      visit catalog_index_path
      click_link 'My Profile'
      page.should have_content('Spider Man')
    end
  end

  context "searching" do
    before do
      FactoryGirl.create(:account, name: 'Marguerite Scypion' )
    end
    it 'without edit access is not displayed in the results' do
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Marguerite'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to_not have_link('Marguerite Scypion') #title
      end
    end
  end

  context "searching" do
    let!(:account) { FactoryGirl.create(:account, name: 'The Hulk') }
    let!(:user) { account.user }
    let!(:person) { account.person }
    before { login_as(user) }
    it 'with edit access is displayed in the results' do
      create_work
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Hulk'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to have_link('The Hulk') #title
      end
    end
  end

  context 'A person when logged in' do
    let(:password) { FactoryGirl.attributes_for(:user).fetch(:password) }
    let(:account) { FactoryGirl.create(:account, name: 'Iron Man') }
    let(:user) { account.user }
    let(:person) { account.person }
    let(:image_file){ Rails.root.join('../fixtures/files/image.png') }
    before do
      login_as(user)
    end

    it 'should have a profile image in show view' do
      create_image(image_file)
      visit('/')
      click_link "My Profile"
      page.should have_css("img[src$='/downloads/#{person.pid}?datastream_id=medium']")
    end

    it 'should show gravatar image if profile image not uploaded' do
      visit('/')
      click_link "My Profile"
      page.should have_css("img[contains(gravatar)]")
    end
  end

  def create_image(image_file)
    visit("/")
    click_link "My Profile"
    click_link "Update Personal Information"
    within('form.edit_user') do
      attach_file("Upload the file", image_file)
      fill_in("user[current_password]", with: password)
      click_button "Update Account"
    end
  end

  protected

  def create_work
    visit("/")
    click_link "add-content"
    classify_what_you_are_uploading 'Generic Work'
    within '#new_generic_work' do
      fill_in "* Title", with: "test work"
      select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
      check("I have read and accept the contributor license agreement")
      click_button("Create Generic work")
    end
  end

end
