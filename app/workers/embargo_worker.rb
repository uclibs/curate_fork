class EmbargoWorker

  def queue_name
    :permissions
  end

  attr_accessor :pid

  def initialize(pid)
    self.pid = pid
  end

  def run
    work = ActiveFedora::Base.find(pid, cast: true)
    work.embargo_release_date = Date.tomorrow
    work.save

    work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    work.save
  end
end

