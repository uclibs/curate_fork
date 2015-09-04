class GroupsReport < Report

  private

  def self.report_objects
    Hydramata::Group.all
  end

  def self.fields(group = Hydramata::Group.new)
    [
      { pid: group.pid },
      { title: group.title },
      { depositor: group.depositor }, 
      { edit_users: group.edit_users.join(" ") }, 
      { members: group.member_ids.join(" ") }
    ]
  end
end
