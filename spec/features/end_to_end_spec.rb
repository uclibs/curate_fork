require 'spec_helper'


describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe 'end to end behavior', FeatureSupport.options(describe_options) do
  let(:sign_in_count) { 0 }
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }
  before do
    user.agreed_to_terms_of_service = agreed_to_terms_of_service
    user.sign_in_count = sign_in_count
    user.save
  end

  let(:another_user) { FactoryGirl.create(:user, agreed_to_terms_of_service: true) }
  let(:another_person) { FactoryGirl.create(:person_with_user) }
  let(:prefix) { Time.now.strftime("%Y-%m-%d-%H-%M-%S-%L") }
  let(:initial_title) { "#{prefix} Something Special" }
  let(:initial_file_path) { __FILE__ }
  let(:updated_title) { "#{prefix} Another Not Quite" }
  let(:updated_file_path) { Rails.root.join('app/controllers/application_controller.rb').to_s }


  def fill_out_form_multi_value_for(method_name, options={})
    field_name = "generic_work[#{method_name}][]"

    within(".control-group.generic_work_#{method_name}.multi_value") do
      elements = [options[:with]].flatten.compact
      if with_javascript?
        elements.each_with_index do |element, i|
          container = all('.input-append').last
          within(container) do
            fill_in(field_name, with: element)
            click_on('Add')
          end
        end
      else
        fill_in(field_name, with: elements.first)
      end
    end
  end

  describe 'terms of service' do
    let(:agreed_to_terms_of_service) { false }
    it "only requires me to agree once" do
      login_as(user)
      visit('/')
      agree_to_terms_of_service
      logout

      visit('/')

      login_as(user)
      page.assert_selector('#terms_of_service', count: 0)
    end
  end

  describe 'with user who has already agreed to the terms of service' do
    let(:agreed_to_terms_of_service) { true }
    let(:test_group_1) { FactoryGirl.create(:group, :title=>"Test Group 1")}
    it "displays the start uploading" do
      login_as(user)
      visit '/'
      click_link("add-content")
      page.should have_content("What are you uploading?")
    end

    it "allows me to directly create a generic work" do
      login_as(user)
      visit new_curation_concern_generic_work_path

      page.assert_selector('.main-header h2', "Describe Your Work")
    end

    it 'sends generic_work error alert when data was invalid' do
      login_as(user)

      visit new_curation_concern_generic_work_path

      CurationConcern::BaseActor.any_instance.stub(:apply_access_permissions)

      create_generic_work(
        'Visibility' => 'visibility_open',
        'I Agree' => true,
        'Creator' => 'Dante',
        'Title' => ''
      )
      
      within('.alert.error') do
        page.should have_content('A virus/error was found in one of the uploaded files.')
      end

#      expect(page).to have_checked_field('visibility_open')
#      expect(page).to_not have_checked_field('visibility_restricted')
    end

    it "a public item with future embargo is not visible today but is in the future" do
      # Because the JS will transform an unexpected input entry to the real
      # today (browser's date), and I want timecop to help
      embargo_release_date = 1.days.from_now
      embargo_release_date_formatted = embargo_release_date.strftime("%Y-%m-%d")
      
      # Make sure the title is unique
      title = SecureRandom.uuid
      
      login_as(user)
      visit new_curation_concern_generic_work_path
      
      # Timecop doesn't work for just changing the system date because Solr uses it's own system date for the embargo queries,
      # and Active Fedora doesn't allow an embargo date in the past.
      # Under embargo test steps: Set the embargo date to one day from now. Run tests to make sure object is under embargo.
      # Out of embargo test steps: Go back to one week before today and set the embargo date to a day after that.
      # Return to now. Run tests.

      create_generic_work(
        "Title" => title,
        'Embargo Release Date' => embargo_release_date_formatted,
        'Visibility' => 'visibility_embargo',
        'Creator' => 'Dante',
        'I Agree' => true
      )

      page.assert_selector(".embargo_release_date.attribute", text: embargo_release_date_formatted)
      page.assert_selector(".permission.attribute", text: "Open Access")


      noid = page.current_path.split("/").last
      
      # The embargo'd object should show up in a search for the owner
      search_catalog_for_title(title)
      page.assert_selector('a', text: title)

      # The owner should be able to see the embargo'd object's show view
      visit("/concern/generic_works/#{noid}")
      page.assert_no_selector('h1', text: "Unauthorized")

      logout
      
      # Assign the work to a group
      work = ActiveFedora::Base.find("sufia:#{noid}", :cast => :true)
      work.add_editor_group(test_group_1)
      work.save!
      #Assign a different user to the group
      test_group_1.add_member(another_person)
      test_group_1.save!
      login_as(another_person.user)

      # The embargo'd object should show up in a search for someone in a group that has access
      search_catalog_for_title(title)
      page.assert_selector('a', text: title)

      # Someone in a group that has access should be able to see the embargo'd object's show view
      visit("/concern/generic_works/#{noid}")
      page.assert_no_selector('h1', text: "Unauthorized")

      logout

      # An anonymous user should not be able to see the embargo'd object in the search results.
      search_catalog_for_title(title)
      page.assert_no_selector('a', text: title)

      # An anonymous user should not be able to see the embargo'd object's show view.
      visit("/concern/generic_works/#{noid}")
      page.assert_selector('h1', text: "Unauthorized")
      
      login_as(user)
      
      # Go back a 1/1/2014
      new_time = Time.local(2014, 1, 1)
      Timecop.travel(new_time) do
        
        # Set embargo date to one day from "now"
        work.embargo_release_date = (Time.now + 1.day).strftime("%Y-%m-%d")
        work.save!
        
        # Go back to now
        Timecop.return

        # The embargo'd object should still show up in a search for the owner
        search_catalog_for_title(title)
        page.assert_selector('a', text: title)
      
        # The owner should still be able to see the embargo'd object's show view
        visit("/concern/generic_works/#{noid}")
        page.assert_no_selector('h1', text: "Unauthorized")   
      
        logout

        login_as(another_person.user)

         # The embargo'd object should still show up in a search for someone in a group that has access
        search_catalog_for_title(title)
        page.assert_selector('a', text: title)
      
        # Someone in a group that has access should still be able to see the embargo'd object's show view
        visit("/concern/generic_works/#{noid}")
        page.assert_no_selector('h1', text: "Unauthorized") 

        logout

        # An anonymous user should now be able to see the embargo'd object in the search results.
        search_catalog_for_title(title)
        page.assert_selector('a', text: title)

        # An anonymous user should now be able to see the embargo'd object's show view.
        visit("/concern/generic_works/#{noid}")
        page.assert_no_selector('h1', text: "Unauthorized")
      end
    end

  end

  describe 'help request' do
    let(:agreed_to_terms_of_service) { true }
    let(:sign_in_count) { 2 }
    it "with JS is available for users who are authenticated and agreed to ToS", js: true do
      login_as(user)
      visit('/')
      click_link "Help!"
      within("#new_help_request") do
        fill_in('How can we help you', with: "I'm trapped in a fortune cookie factory!")
        click_on("Let Us Know")
      end
      page.assert_selector('.notice', text: HelpRequestsController::SUCCESS_NOTICE)
    end

    it "without JS is available for users who are authenticated and agreed to ToS", js: false do
      login_as(user)
      visit('/')
      click_link "Help!"
      within("#new_help_request") do
        fill_in('How can we help you', with: "I'm trapped in a fortune cookie factory!")
        click_on("Let Us Know")
      end
      page.assert_selector('.notice', text: HelpRequestsController::SUCCESS_NOTICE)
    end
  end

  describe '+Add javascript behavior', js: true do
    let(:creators) { ["D'artagnan", "Porthos", "Athos", 'Aramas'] }
    let(:agreed_to_terms_of_service) { true }
    let(:title) {"Somebody Special's Generic Work" }
    xit 'handles contributor', js: true do
      login_as(user)
      visit new_curation_concern_generic_work_path
      create_generic_work(
        "Title" => title,
        "Upload a file" => initial_file_path,
        "Creator" => creators,
        "I Agree" => true,
        :js => true
      )
      page.should have_content(title)
      creators.each do |creator|
        page.assert_selector(
          '.generic_work.attributes .creator.attribute',
          text: creator
        )
      end
    end
  end

  describe 'with a user who has not agreed to terms of service' do
    let(:agreed_to_terms_of_service) { false }
    let(:sign_in_count) { 20 }
    it "displays the terms of service page after authentication" do
      login_as(user)
      visit('/')
      agree_to_terms_of_service
      classify_what_you_are_uploading('Generic Work')
      create_generic_work('I Agree' => true, 'Visibility' => 'visibility_open')
      path_to_view_work = view_your_new_work
      path_to_edit_work = edit_your_work
      view_your_updated_work

      #needs to be updated to accomodate UI changes
      #view_your_dashboard

      logout
      login_as(another_user)
      other_persons_work_is_not_in_my_dashboard
      i_can_see_another_users_open_resource(path_to_view_work)
      i_cannot_edit_to_another_users_resource(path_to_edit_work)
    end
  end

  protected

  def agree_to_terms_of_service
    within('#terms_of_service') do
      click_on("I Agree")
    end
  end

  def create_generic_work(options = {})
    options['Title'] ||= initial_title
    options['Upload a file'] ||= initial_file_path
    options['Visibility'] ||= 'visibility_restricted'
    options["Button to click"] ||= "Create Generic work"
    options["Creator"] ||= "Dante"
    options["DOI Strategy"] ||= CurationConcern::RemotelyIdentifiedByDoi::NOT_NOW
    options["Content License"] ||= Sufia.config.cc_licenses.keys.first.dup

    # Without accepting agreement
    within('#new_generic_work') do
      fill_in("Title", with: options['Title'])
      attach_file("Upload a file", options['Upload a file'])
      choose(options['Visibility'])
      if options['Embargo Release Date']
        fill_in("generic_work_embargo_release_date", with: options["Embargo Release Date"])
      end

      select(options['Content License'], from: I18n.translate('sufia.field_label.rights'))

      fill_in("generic_work_creator", with: options['Creator'])

      if options['DOI Strategy']
        choose("generic_work_doi_assignment_strategy_#{options['DOI Strategy']}")
      end

      if options['I Agree']
        check("I have read and accept the contributor license agreement")
      end
      click_on(options["Button to click"])
    end

    unless options["I Agree"]
      within('.alert.error') do
        page.should have_content('You must accept the contributor agreement')
      end
    end
  end

  def add_a_related_file(options = {})
    options['Title'] ||= initial_title
    options['Upload a file'] ||= initial_file_path
    options['Visibility'] ||= 'visibility_restricted'
    within("form.new_generic_file") do
      fill_in("Title", with: options['Title'])
      attach_file("Upload a file", options['Upload a file'])
      choose(options['Visibility'])
      click_on("Attach to Generic Work")
    end
  end

  def view_your_new_work
    path_to_view_work  = page.current_path
    page.should have_content("Files")
    page.should have_content(initial_title)
    within(".generic_file.attributes") do
      page.should have_content(File.basename(initial_file_path))
    end

    return path_to_view_work
  end

  def edit_your_work
    click_on("Edit This Generic Work")
    edit_page_path = page.current_path
    within('.edit_generic_work') do
      fill_in("Title", with: updated_title)
      fill_in("Description", with: "Lorem Ipsum")
      click_on("Update Generic work")
    end
    return edit_page_path
  end

  def view_your_updated_work
    page.should have_content("Files")
    page.should have_content(updated_title)
    click_on("home-link")
  end

  def view_your_dashboard
    search_term = "\"#{updated_title}\""
    within(".search-query-form") do
      fill_in("q", with: search_term)
      click_on("keyword-search-submit")
    end

    within('#documents') do
      page.should have_content(updated_title)
    end
    within('.alert.alert-info') do
      page.should have_content("Limited to: #{search_term}")
    end

    within('#facets') do
      # I call CSS/Dom shenannigans; I can't access 'Creator' link
      # directly and instead must find by CSS selector, validate it
      all('a.accordion-toggle').each do |elem|
        if elem.text =~ /^Type/
          elem.click
          break
        end
      end
      click_on('Generic Work')

    end
    within('.alert.alert-info') do
      page.should have_content("Limited to: #{search_term}")
    end
    within('.alert.alert-warning') do
      page.should have_content('Generic Work')
    end
  end

  def other_persons_work_is_not_in_my_dashboard
    visit "/catalog"
    click_on 'My Works'
    click_on 'aux-search-submit-header'  # this is hidden if javascript is enabled
    search_term = "\"#{updated_title}\""
    within(".search-form") do
      fill_in("q", with: search_term)
      click_on("keyword-search-submit")
    end
    within('#documents') do
      page.should_not have_content(updated_title)
    end
  end

  def i_can_see_another_users_open_resource(path_to_other_persons_resource)
    visit path_to_other_persons_resource
    page.should have_content(updated_title)
  end

  def i_cannot_edit_to_another_users_resource(path_to_other_persons_resource)
    visit path_to_other_persons_resource
    page.should_not have_content(updated_title)
  end

  def search_catalog_for_title(title)
    visit("/")
    within(".search-form") do
      fill_in("catalog_search", with: title)
      click_on("keyword-search-submit")
    end
  end

end
