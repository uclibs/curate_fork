class Collection < ActiveFedora::Base
  include Hydra::Collection
  include Hydra::AccessControls::Permissions
  include Hydra::AccessControls::WithAccessRight
  include Sufia::Noid

  has_many :associated_persons, property: :has_profile, class_name: 'Person'

  # Defaults to "Collection", but can be set to something else.
  # Profiles are marked with human_readable_type of "Profile" when they're created by the associated Person object
  # This is used to populate the Object Type Facet
  def human_readable_type
    @human_readable_type ||= 'Collection'
  end
  attr_writer :human_readable_type

  def is_profile?
    !associated_persons.empty?
  end

  def to_s
    self.title.nil? ? self.inspect : self.title
  end

  def to_solr(solr_doc={}, opts={})
    super
    Solrizer.set_field(solr_doc, 'generic_type', 'Collection', :facetable)
    Solrizer.set_field(solr_doc, 'human_readable_type', human_readable_type, :facetable)
    solr_doc
  end

  # ------------------------------------------------
  # overriding method from active-fedora:
  # lib/active_fedora/semantic_node.rb
  #
  # The purpose of this override is to ensure that
  # a collection cannot contain itself.
  #
  # TODO:  After active-fedora 7.0 is released, this
  # logic can be moved into a before_add callback.
  # ------------------------------------------------
  def add_relationship(predicate, target, literal=false)
    return if self == target
    super
  end

end
