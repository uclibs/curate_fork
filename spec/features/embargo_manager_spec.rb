require 'spec_helper'
require 'rake'

describe EmbargoWorker do
  context "an embargoed work" do
    let(:embargo_date) { Date.tomorrow }
    let(:work) { FactoryGirl.create(:generic_work_with_files, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO, embargo_release_date: embargo_date) }

    it "should be open access after the manager task has run" do
      new_time = Time.now + 1.day
      work

      Timecop.travel(new_time) do
        load File.expand_path("../../../lib/tasks/embargo_manager.rake", __FILE__)
        Rake::Task.define_task(:environment)
    	Rake::Task['embargomanager:release'].invoke

        new_pid = work.pid
        work = ActiveFedora::Base.find(new_pid, cast: true)

    	work.visibility.should == 'open'
        Timecop.return
      end
    end
  end
end
