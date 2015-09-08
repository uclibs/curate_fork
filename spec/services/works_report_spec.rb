require 'spec_helper'

describe WorksReport do
  describe '#report_location' do
    it 'should be vendor/work_report.csv' do
      expect(WorksReport.report_location).to eq("#{Rails.root}/vendor/works_report.csv")
    end
  end

  describe '#create_report' do
    let(:fake_articles) { 
      [ 
        FakeWork.new('pid:1234', 'Title', 'foo@bar.org', 'foo@bar.org', ['pid', 'pid'], ['pid']),
        FakeWork.new('pid:1234', 'Title', 'foo@bar.org', 'foo@bar.org', ['pid'], ['pid'])
      ]
    }
    let(:fake_generic_works) { [] }
    let(:fake_images) { 
      [ 
        FakeWork.new('pid:1234', 'Title', 'foo@bar.org', 'foo@bar.org', ['pid', 'pid'], ['pid']),
        FakeWork.new('pid:1234', 'Title', 'foo@bar.org', 'foo@bar.org', [''], ['pid']) 
      ] 
    }
    let(:fake_datasets) { 
      [ 
        FakeWork.new('pid:1234', 'Title', 'foo@bar.org', 'foo@bar.org', ['pid', 'pid'], [''])
      ]
    }
    let(:fake_documents) { [] }

    before(:each) do
      Article.stub(:all).and_return(fake_articles)
      GenericWork.stub(:all).and_return(fake_generic_works)
      Image.stub(:all).and_return(fake_images)
      Dataset.stub(:all).and_return(fake_datasets)
      Document.stub(:all).and_return(fake_documents)

      File.delete(WorksReport.report_location) if File.exist?(WorksReport.report_location)
    end

    it 'should create a report in the report_location' do
      WorksReport.create_report
      expect(File).to exist(WorksReport.report_location) 
    end

    it 'should create a report one line longer than the number of objects reported on' do
      WorksReport.create_report
      expect(
        File.open(WorksReport.report_location).readlines.size
      ).to eq(
        (fake_articles + fake_generic_works + fake_images + fake_datasets + fake_documents).length + 1)
    end

    class FakeWork < Struct.new(:pid, :title, :owner, :depositor, :editor_ids, :editor_group_ids)
    end
  end
end
