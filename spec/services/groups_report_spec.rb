require 'spec_helper'

describe GroupsReport do
  describe '#report_location' do
    it 'should be vendor/groups_report.csv' do
      expect(GroupsReport.report_location).to eq("#{Rails.root}/vendor/groups_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_groups) { [ 
      FakeGroup.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid', 'pid']),
      FakeGroup.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid']),
      FakeGroup.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['']),
      FakeGroup.new('pid', 'title', 'foo@bar.org', ['foo@bar.org'], ['pid', 'pid']) 
    ] }

    before(:each) do
      Hydramata::Group.stub(:all).and_return(fake_groups)

      File.delete(GroupsReport.report_location) if File.exist?(GroupsReport.report_location)
    end

    it 'should create a report in the report_location' do
      GroupsReport.create_report
      expect(File).to exist(GroupsReport.report_location) 
    end

    it 'should create a report one line longer than the number of objects reported on' do
      GroupsReport.create_report
      expect(
        File.open(GroupsReport.report_location).readlines.size
      ).to eq(fake_groups.length + 1)
    end

    class FakeGroup < Struct.new(:pid, :title, :depositor, :edit_users, :member_ids)
    end
  end
end
