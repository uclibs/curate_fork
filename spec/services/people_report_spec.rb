require 'spec_helper'

describe PeopleReport do
  describe '#report_location' do
    it 'should be vendor/people_report.csv' do
      expect(PeopleReport.report_location).to eq("#{Rails.root}/vendor/people_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_people) { [ 
      FakePerson.new('pid', 'foo@bar.org', 'foo@bar.org', FakeUserForDelegate.new([FakeDelegate.new('foo@bar.org')]), ["foobar@example.org"]),
    ] }

    before(:each) do
      Person.stub(:all).and_return(fake_people)

      File.delete(PeopleReport.report_location) if File.exist?(PeopleReport.report_location)
    end

    it 'should create a report in the report_location' do
      PeopleReport.create_report
      expect(File).to exist(PeopleReport.report_location) 
    end

    it 'should create a report one line longer than the number of objects reported on' do
      PeopleReport.create_report
      expect(
        File.open(PeopleReport.report_location).readlines.size
      ).to eq(fake_people.length + 1)
    end

    class FakePerson < Struct.new(:pid, :depositor, :email, :user, :edit_users)
    end

    class FakeUserForDelegate < Struct.new(:can_receive_deposits_from)
    end

    class FakeDelegate < Struct.new(:email)
    end
  end
end
