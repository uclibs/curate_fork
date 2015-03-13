require 'spec_helper'

describe DelegateEditorCleanupWorker do

  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }
  let(:grantee) { FactoryGirl.create(:person_with_user) }
  let(:another_user) { grantee.user }
  let(:generic_work_w_condition) { FactoryGirl.create(:generic_work, depositor: grantee.email, user: user, edit_users: [grantee.email]) }
  let(:generic_work_wo_condition) { FactoryGirl.create(:generic_work, user: user, owner: user.email) }
  let(:pids) {{:grantor=>person.pid, :grantee=>grantee.pid}}
  let(:nilpids) {{:grantee =>nil, :grantor =>nil}}

  it 'should raise error when no grantor pid' do
    expect{
      DelegateEditorCleanupWorker.new(nilpids)
    }.to raise_error( DelegateEditorCleanupWorker::GrantError )
  end

  it 'should raise error when no grantee pid' do
    expect{
      DelegateEditorCleanupWorker.new(nilpids)
    }.to raise_error( DelegateEditorCleanupWorker::GrantError )
  end


  context 'for valid pid' do
    before do
        person.user.can_receive_deposits_from << grantee.user
    end

    it 'should change editor on qualified works' do
      
      expect(generic_work_w_condition.edit_users).to include (grantee.email)
      
      DelegateEditorCleanupWorker.new(pids).run
      
      expect(generic_work_w_condition.reload.edit_users).not_to include (grantee.email)

    end

    it 'should not change editor on unqualified works' do

      expect(generic_work_wo_condition.edit_users).to eq [user.email]

      DelegateEditorCleanupWorker.new(pids).run

      expect(generic_work_wo_condition.edit_users).to eq [user.email]

    end
  
  end
end
