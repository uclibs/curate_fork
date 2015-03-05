# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController
  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BreadcrumbsOnRails::ActionController
  include Curate::ThemedLayoutController
  include Curate::FieldsForAddToCollection
  include Hydramata::SolrHelper

  with_themed_layout 'catalog'

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show
  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # Enforce embargo on all Solr queries
  CatalogController.solr_search_params_logic += [:enforce_embargo]
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic += [:exclude_unwanted_models]
  CatalogController.solr_search_params_logic += [:show_only_works]
  CatalogController.solr_search_params_logic += [:show_only_editors]
  before_filter :agreed_to_terms_of_service!

  skip_before_filter :default_html_head

  def index
    collection_options
    super
  end

  def self.uploaded_field
    #  system_create_dtsi
    solr_name('desc_metadata__date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('desc_metadata__date_modified', :stored_sortable , type: :date)
  end

  def self.search_config
     # Set parameters to send to SOLR
     # First inspect contents of the hash from Yaml configuration file
     # See config/search_config.yml
     initialized_config = Curate.configuration.search_config['catalog']
     # If the hash is empty, set reasonable defaults for this search type
     if initialized_config.nil?
        Hash['qf' => ['desc_metadata__title_tesim','desc_metadata__name_tesim'],'qt' => 'search','rows' => 10]
     else
        initialized_config
     end
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qf: search_config['qf'],
      qt: search_config['qt'],
      rows: search_config['rows']
    }

    # solr field configuration for search results/index views
    config.index.show_link = solr_name("desc_metadata__title", :stored_searchable)
    config.index.record_display_type = "id"

    # solr field configuration for document/show views
    config.show.html_title = solr_name("desc_metadata__title", :stored_searchable)
    config.show.heading = solr_name("desc_metadata__title", :stored_searchable)
    config.show.display_type = solr_name("has_model", :symbol)

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type of Work", limit: 5
    config.add_facet_field solr_name(:desc_metadata__creator, :facetable), label: "Creator", helper_method: :creator_name_from_pid, limit: 5

    config.add_facet_field solr_name("desc_metadata__tag", :facetable), label: "Keyword", limit: 5
    config.add_facet_field solr_name("desc_metadata__subject", :facetable), label: "Subject", limit: 5
    config.add_facet_field solr_name("desc_metadata__language", :facetable), label: "Language", limit: 5
    config.add_facet_field solr_name("desc_metadata__based_near", :facetable), label: "Location", limit: 5
    config.add_facet_field solr_name("desc_metadata__publisher", :facetable), label: "Publisher", limit: 5
    config.add_facet_field solr_name("file_format", :facetable), label: "File Format", limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_index_field solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_index_field solr_name("desc_metadata__tag", :stored_searchable, type: :string), label: "Keyword"
    config.add_index_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_index_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_index_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_index_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_index_field solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_index_field solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_index_field solr_name("desc_metadata__date_uploaded", :stored_sortable, type: :string), label: "Date Uploaded"
    config.add_index_field solr_name("desc_metadata__date_modified", :stored_sortable, type: :string), label: "Date Modified"
    config.add_index_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_index_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_index_field solr_name("human_readable_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_index_field solr_name("desc_metadata__format", :stored_searchable, type: :string), label: "File Format"
    config.add_index_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("desc_metadata__title", :stored_searchable, type: :string), label: "Title"
    config.add_show_field solr_name("desc_metadata__description", :stored_searchable, type: :string), label: "Description"
    config.add_show_field solr_name("desc_metadata__tag", :stored_searchable, type: :string), label: "Keyword"
    config.add_show_field solr_name("desc_metadata__subject", :stored_searchable, type: :string), label: "Subject"
    config.add_show_field solr_name("desc_metadata__creator", :stored_searchable, type: :string), label: "Creator"
    config.add_show_field solr_name("desc_metadata__contributor", :stored_searchable, type: :string), label: "Contributor"
    config.add_show_field solr_name("desc_metadata__publisher", :stored_searchable, type: :string), label: "Publisher"
    config.add_show_field solr_name("desc_metadata__based_near", :stored_searchable, type: :string), label: "Location"
    config.add_show_field solr_name("desc_metadata__language", :stored_searchable, type: :string), label: "Language"
    config.add_show_field solr_name("desc_metadata__date_uploaded", :stored_searchable, type: :string), label: "Date Uploaded"
    config.add_show_field solr_name("desc_metadata__date_modified", :stored_searchable, type: :string), label: "Date Modified"
    config.add_show_field solr_name("desc_metadata__date_created", :stored_searchable, type: :string), label: "Date Created"
    config.add_show_field solr_name("desc_metadata__rights", :stored_searchable, type: :string), label: "Rights"
    config.add_show_field solr_name("human_readable_type", :stored_searchable, type: :string), label: "Resource Type"
    config.add_show_field solr_name("desc_metadata__format", :stored_searchable, type: :string), label: "File Format"
    config.add_show_field solr_name("desc_metadata__identifier", :stored_searchable, type: :string), label: "Identifier"

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields', :include_in_advanced_search => false) do |field|
      title_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
      label_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
      contributor_name = solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
      field.solr_parameters = {
        :qf => "#{title_name} noid_tsi #{label_name} file_format_tesim #{contributor_name}",
        :pf => "#{title_name}"
      }
    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :"spellcheck.dictionary" => "contributor" }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = solr_name("desc_metadata__contributor", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end



    config.add_search_field('creator') do |field|
      field.solr_parameters = { :"spellcheck.dictionary" => "creator" }
      solr_name = solr_name("desc_metadata__creator", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "title"
      }
      solr_name = solr_name("desc_metadata__title", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "description"
      }
      solr_name = solr_name("desc_metadata__description", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "publisher"
      }
      solr_name = solr_name("desc_metadata__publisher", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "date_created"
      }
      solr_name = solr_name("desc_metadata__created", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "subject"
      }
      solr_name = solr_name("desc_metadata__subject", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('language') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "language"
      }
      solr_name = solr_name("desc_metadata__language", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('human_readable_type') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "human_readable_type"
      }
      solr_name = solr_name("human_readable_type", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('format') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "format"
      }
      solr_name = solr_name("desc_metadata__format", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        :"spellcheck.dictionary" => "identifier"
      }
      solr_name = solr_name("desc_metadata__id", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      field.solr_parameters = {
        :"spellcheck.dictionary" => "based_near"
      }
      solr_name = solr_name("desc_metadata__based_near", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('tag') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "tag"
      }
      solr_name = solr_name("desc_metadata__tag", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('depositor') do |field|
      solr_name = solr_name("desc_metadata__depositor", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end

    config.add_search_field('rights') do |field|
      solr_name = solr_name("desc_metadata__rights", :stored_searchable, type: :string)
      field.solr_local_parameters = {
        :qf => solr_name,
        :pf => solr_name
      }
    end


    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance \u25BC"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  protected

    # Override Hydra::PolicyAwareAccessControlsEnforcement
    def gated_discovery_filters
      if current_user and current_user.manager?
        return []
      end
      super
    end

    # Overriding blacklight so that the search results can be displayed in a way compatible with
    # tokenInput javascript library.  This is used for suggesting "Related Works" to attach.
    def render_search_results_as_json
      {"docs" => @response["response"]["docs"].map {|solr_doc| serialize_work_from_solr(solr_doc) }}
    end

    def serialize_work_from_solr(solr_doc)
      title = solr_doc["desc_metadata__title_tesim"].first
      title << " (#{solr_doc["human_readable_type_tesim"].first})" if solr_doc["human_readable_type_tesim"].present?
      {
        pid: solr_doc["id"],
        title: title
      }
    end

    # show only files with edit permissions in lib/hydra/access_controls_enforcement.rb apply_gated_discovery
    def discovery_permissions
      return ["edit"] if params[:works] == 'mine'
      super
    end


    # Limits search results just to GenericFiles
    # @param solr_parameters the current solr parameters
    # @param user_parameters the current user-subitted parameters
    def exclude_unwanted_models(solr_parameters, user_parameters)
      super
      solr_parameters[:fq] ||= []
      [GenericFile, Profile, ProfileSection, LinkedResource,
       Hydramata::Group].each do |klass|
        solr_parameters[:fq] << exclude_class_filter(klass)
      end
    end

    #Excludes collection and person only when trying to filter by work.
    # This is included as part of blacklight search solr params logic
    def show_only_works(solr_parameters, user_parameters)
      if params.has_key?(:f) and params[:f].to_a.flatten == ["generic_type_sim","Work"]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "-has_model_ssim:\"info:fedora/afmodel:Collection\""
        solr_parameters[:fq] << "-has_model_ssim:\"info:fedora/afmodel:Person\""
      end
    end

    #Excludes people without edit access to at least one work
    #Applies to all searches
    def show_only_editors(solr_parameters, user_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "-(-is_editor_of_ssim:[* TO *] OR has_model_ssim:\"info:fedora/afmodel:Person\")"
    end

    def depositor
      #Hydra.config[:permissions][:owner] maybe it should match this config variable, but it doesn't.
      Solrizer.solr_name('depositor', :stored_searchable, type: :string)
    end

    def sort_field
      "#{Solrizer.solr_name('system_create', :sortable)} desc"
    end

    def exclude_class_filter(klass)
      '-' + ActiveFedora::SolrService.construct_query_for_rel(has_model:
                                                        klass.to_class_uri)
    end
end
