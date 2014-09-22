Docket.configure do |config|
  # AWS account configuration:

  config.aws.access_key = ENV['AWS_ACCESS_KEY']
  config.aws.secret_key = ENV['AWS_SECRET_KEY']
  config.aws.region = ENV['AWS_REGION']

  if Rails.env.development?
    config.sns.endpoint = "http://#{config.aws.region}.localhost:6061"
  end

  Docket::Logging.logger = Rails.logger
end
