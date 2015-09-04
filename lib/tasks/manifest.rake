namespace :manifest do
  desc "Run all manifest reports"
  task :all => [:works, :files, :people, :profiles, :users, :collections, :groups, :linked_resources] do
  end

  task :works => :environment do
    WorksReport.create_report
  end

  task :files => :environment do
    FilesReport.create_report
  end

  task :people => :environment do
    PeopleReport.create_report
  end

  task :profiles => :environment do
    ProfilesReport.create_report
  end

  task :users => :environment do
    UsersReport.create_report
  end

  task :collections => :environment do
    CollectionsReport.create_report
  end

  task :groups => :environment do
    GroupsReport.create_report
  end

  task :linked_resources => :environment do
    LinkedResourcesReport.create_report
  end
end
