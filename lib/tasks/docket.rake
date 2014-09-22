namespace :docket do
  desc %Q{Sends a message (options: TOPIC=my-topic, BODY='{attr1:"val1"}')}
  task :message => :environment do
    Docket::ConsoleSender.new(ENV['TOPIC'], ENV['BODY']).send!
  end
end
