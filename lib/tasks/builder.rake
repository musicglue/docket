namespace :docket do

  desc "Create and set up the AWS environment"
  task :build => :environment do
    Docket::Builder.new(Docket.config.builder.path).build!
  end

end
