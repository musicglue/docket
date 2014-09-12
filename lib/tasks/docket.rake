namespace :docket do
  desc "Create and set up the AWS environment"
  task :build => :environment do
    Docket::Builder.new(Docket.config.builder.path).build!
  end

  desc %Q{Sends a message (options: TOPIC=my-topic, BODY='{attr1:"val1"}')}
  task :message => :environment do
    Docket::ConsoleSender.new(ENV['TOPIC'], ENV['BODY']).send!
  end
end
