class ProfilesReport < Report

  private

  def self.report_objects
    Profile.all
  end

  def self.fields(profile = Profile.new)
    [
      { pid: profile.pid },
      { title: profile.title }, 
      { depositor: profile.depositor },
      { edit_users: profile.edit_users.join(" ") },
    ]
  end
end
