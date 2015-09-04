class WorksReport < Report

  private

  def self.report_objects
    works = Array.new
    work_type_classes.each do |type_class|
      type_class.all.each { |work| works << work }
    end
    works
  end

  def self.fields(work = GenericWork.new)
    [
      { pid: work.pid },
      { title: work.title },
      { owner: work.owner },
      { depositor: work.depositor },
      { editors: work.editor_ids.join(" ") },
      { editor_groups: work.editor_group_ids.join(" ") }
    ]
  end

  def self.work_type_classes
    Curate.configuration.registered_curation_concern_types.collect { |type| type.constantize }
  end
end
