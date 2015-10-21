require 'spec_helper'

describe LinkedResourcesReport do
  describe '#report_location' do
    it 'should be vendor/linked_resources_report.csv' do
      expect(LinkedResourcesReport.report_location).to eq("#{Rails.root}/vendor/linked_resources_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_linked_resources) { [ 
      FakeLinkedResource.new('pid', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org']),
      FakeLinkedResource.new('pid', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org']),
      FakeLinkedResource.new('pid', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org']),
      FakeLinkedResource.new('pid', 'foo@bar.org', 'foo@bar.org', ['foo@bar.org'])
    ] }

    before(:each) do
      LinkedResource.stub(:all).and_return(fake_linked_resources)

      File.delete(LinkedResourcesReport.report_location) if File.exist?(LinkedResourcesReport.report_location)
    end

    it 'should create a report in the report_location' do
      LinkedResourcesReport.create_report
      expect(File).to exist(LinkedResourcesReport.report_location) 
    end

    it 'should create a report one line longer than the number of objects reported on' do
      LinkedResourcesReport.create_report
      expect(
        File.open(LinkedResourcesReport.report_location).readlines.size
      ).to eq(fake_linked_resources.length + 1)
    end

    class FakeLinkedResource < Struct.new(:pid, :owner, :depositor, :edit_users)
    end
  end
end
