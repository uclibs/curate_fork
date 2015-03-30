require 'spec_helper'

describe DelegateEditorAssignWorker do

  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }
  let(:grantee) { FactoryGirl.create(:person_with_user) }
  let(:another_user) { grantee.user }
  let(:generic_work_w_condition) { FactoryGirl.create(:generic_work, depositor: user.email, user: user, edit_users: [user.email]) }
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

    it 'should assign edit access on qualified works' do
      
      expect(generic_work_w_condition.edit_users).not_to include (grantee.email)
      
      DelegateEditorAssignWorker.new(pids).run
      
      expect(generic_work_w_condition.reload.edit_users).to include (grantee.email)

    end

    it 'should not assign editor on unqualified works' do

      expect(generic_work_wo_condition.edit_users).not_to eq [grantee.email]

      DelegateEditorCleanupWorker.new(pids).run

      expect(generic_work_wo_condition.edit_users).not_to eq [grantee.email]

    end
  
  end
end
