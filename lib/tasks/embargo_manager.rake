namespace :embargomanager do
	desc 'Starts EmbargoWorker to manage expired embargoes'
	task :release => :environment do
  	solr_results = ActiveFedora::SolrService.query( 'embargo_release_date_dtsi:[* TO *]' )
  	solr_results.each do |work|
      if Date.parse(work['embargo_release_date_dtsi']) <= Date.today
      	Sufia.queue.push(EmbargoWorker.new(work['id']))
      end
    end
  end
end