require 'spec_helper'

describe "scrub_params" do
  describe "passing known and unknown parameters" do
    before do
      helper.stub(:blacklight_config => double(:facet_fields => {}))
      helper.params["controller"] = "catalog"
      helper.params["action"] = "index"
      helper.params["f"] = {"generic_type_sim" => ['Work']}
      helper.params["fakeparam"] = "hack"
    end
    it "should remove just the unknown parameters" do
      helper.scrub_params(params)
      helper.params["controller"].should == "catalog"
      helper.params["action"].should == "index"
      helper.params["f"].should == {"generic_type_sim" => ['Work']}
      helper.params["fakeparam"].should == nil
    end
  end
end
