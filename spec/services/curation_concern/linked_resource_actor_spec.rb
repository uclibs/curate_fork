require 'spec_helper'

describe CurationConcern::LinkedResourceActor do
  let(:user) { FactoryGirl.create(:user) }
  let(:parent) { FactoryGirl.create(:generic_work, user: user) }
  let(:link) { LinkedResource.new.tap {|lr| lr.batch = parent } }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  def reload_resource(resource)
    resource.class.find(resource.pid)
  end

  subject {
    CurationConcern::LinkedResourceActor.new(link, user, url: you_tube_link)
  }

  describe '#create' do
    describe 'success' do
      it 'adds a linked resource to the parent work' do
        parent.linked_resources.should == []
        subject.create
        reload_resource(parent).linked_resources.should == [link]
        reloaded_link = reload_resource(link)
        reloaded_link.batch.should == parent
        reloaded_link.url.should == you_tube_link
      end
    end

    describe 'failure' do
      it 'returns false' do
        link.stub(:valid?).and_return(false)
        CurationConcern::BaseActor.any_instance.stub(:apply_access_permissions)
        return_value = 'some value'
        expect {
          return_value = subject.create
        }.to_not change { LinkedResource.count }
        reload_resource(parent).linked_resources.should == []
        return_value.should be_false
      end
    end
  end

end
