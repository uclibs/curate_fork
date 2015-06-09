namespace :embargomanager do
  desc 'Starts EmbargoWorker to manage expired embargoes'
  task :release => :environment do

  #Days before release variables (I see how this may cause confusion, but normally we would want to send the emails 14 and 30 days before release respectivily)
  FOURTEEN = 1
  THIRTY = 2

    solr_results = ActiveFedora::SolrService.query( 'embargo_release_date_dtsi:[* TO *]' )
    solr_results.each do |work|
      if Date.parse(work['embargo_release_date_dtsi']) <= Date.today
      	Sufia.queue.push(EmbargoWorker.new(work['id']))
        receiver = work['depositor_tesim']
        mail_contents = work['desc_metadata__title_tesim']
        EmbargoMailer.notify_open(receiver, mail_contents).deliver
      else if Date.parse(work['embargo_release_date_dtsi']) == (Date.today + FOURTEEN)
        receiver = work['depositor_tesim']
        mail_contents = work['desc_metadata__title_tesim']
        EmbargoMailer.notify_14_days(receiver, mail_contents).deliver
      else if Date.parse(work['embargo_release_date_dtsi']) == (Date.today + THIRTY)
        receiver = work['depositor_tesim']
        mail_contents = work['desc_metadata__title_tesim']
        EmbargoMailer.notify_30_days(receiver, mail_contents).deliver
      end
    end
  end
end
