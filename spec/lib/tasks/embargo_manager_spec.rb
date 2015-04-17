require 'spec_helper'
require 'rake'

describe EmbargoManager do
  describe "an embargoed work" do
	let(:embargo_date) { Date.tomorrow }
    let(:work) { FactoryGirl.create(:generic_work_with_files, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO, embargo_release_date: embargo_date) }
    
    it "should be open access after the manager task has run" do
      new_time = Time.now + 1.day
      Timecop.travel(new_time) do
    	Rake::Task['embargomanager:release'].invoke
    	Timecop.return
    	work.visibility.should = 'open'
      end
    end
  end
end