class CollectionsReport < Report

  private

  def self.report_objects
    Collection.all
  end

  def self.fields(collection = Collection.new)
    [
      { pid: collection.pid },
      { title: collection.title },
      { depositor: collection.depositor },
      { works: collection.member_ids.join(" ") }
    ]
  end
end
