require 'spec_helper'

describe_options = {type: :feature}
if ENV['JS']
  describe_options[:js] = true
end

describe "Visit the catalog index page" do
  context "when the per_page parameter is less than 1" do
    it "returns a custom error page" do
      visit ('/catalog?per_page=0')
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the per_page parameter is out of range" do
    it "returns a custom error page" do
      visit ('/catalog?per_page=1000')
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the page parameter is out of range" do
    it "returns a custom error page" do
      visit ('/catalog?page=1000')
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the q parameter is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?q=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the desc_metadata__creator_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bdesc_metadata__creator_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the desc_metadata__language_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bdesc_metadata__language_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the desc_metadata__publisher_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bdesc_metadata__publisher_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the desc_metadata__subject_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bdesc_metadata__subject_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the generic_type_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bgeneric_type_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the utf8 is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?utf8=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the works is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?works=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the catalog index page" do
  context "when the human_readable_type_sim is out of range" do
    it "returns a custom error page" do
      long_string = ""
      250.times{long_string << "test"}
      visit ("/catalog?f%5Bhuman_readable_type_sim%5D%5B%5D=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end

describe "Visit the collection add member page" do
  let(:user) { FactoryGirl.create(:user) }

  context "when the collectible_id is out of range" do
    it "returns a custom error page" do
      login_as(user)
      long_string = ""
      250.times{long_string << "test"}
      visit ("/collections/add_member_form?collectible_id=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
=begin
  context "when profile_collection_id is out of range" do
    it "returns a custom error page" do
      login_as(user)
      long_string = ""
      250.times{long_string << "test"}

@parameters = { "profile_collection_id"=>"#{long_string}",
                "collectible_id"=>"sufia%3A2f7634481"
              }

post "/collections/add_member", @parameters


i#      visit ("/collections/add_member_form?collectible_id=#{long_string}")
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
=end
end

