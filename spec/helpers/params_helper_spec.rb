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

describe "blind_sql_params_checker" do
  describe "passing valid and invalid parameters" do
    before do
      helper.stub(:blacklight_config => double(:show_fields => {}))
    end
    it "should pass the valid paramters" do
      helper.params["image"]= {"title" => ['Test Title']}
      helper.check_blind_sql_parameters_loop?()
      helper.params["image"]["title"].should == ['Test Title']
    end
    it "should redirect the invalid paramters" do
      helper.params["image"]= {"creator" => ['DBMS_LOCK.SLEEP']}
      expect(helper.check_blind_sql_parameters_loop?).to eq(false)
    end
  end
end
