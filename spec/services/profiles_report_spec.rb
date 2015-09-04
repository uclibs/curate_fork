require 'spec_helper'

describe ProfilesReport do
  describe '#report_location' do
    it 'should be vendor/profiles_report.csv' do
      expect(ProfilesReport.report_location).to eq("#{Rails.root}/vendor/profiles_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_profiles) { [ 
      FakeProfile.new('pid', 'My title', 'foo@bar.org', ["foo@bar.org"]),
      FakeProfile.new('pid', 'My title', 'foo@bar.org', ["foo@bar.org"]),
      FakeProfile.new('pid', 'My title', 'foo@bar.org', ["foo@bar.org"]),
      FakeProfile.new('pid', 'My title', 'foo@bar.org', ["foo@bar.org"])
    ] }

    before(:each) do
      Profile.stub(:all).and_return(fake_profiles)

      File.delete(ProfilesReport.report_location) if File.exist?(ProfilesReport.report_location)
    end

    it 'should create a report in the report_location' do
      ProfilesReport.create_report
      expect(File).to exist(ProfilesReport.report_location) 
    end

    it 'should create a report one line longer than the number of objects reported on' do
      ProfilesReport.create_report
      expect(
        File.open(ProfilesReport.report_location).readlines.size
      ).to eq(fake_profiles.length + 1)
    end

    class FakeProfile < Struct.new(:pid, :title, :depositor, :edit_users)
    end
  end
end
