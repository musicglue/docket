module Docket
  class Builder

    def initialize(file_path, config={})
      @sns_connection = Aws.sns(connection_options.merge((config[:sns] || {})))
      @sqs_connection = Aws.sqs(connection_options.merge((config[:sqs] || {})))

      @manifest = YAML.load(File.read(file_path))[Docket.env].with_indifferent_access
    end

    def build!
      build_sqs if @manifest[:sqs].any?
      build_sns if @manifest[:sns].any?
    end

    def build_sqs
      @manifest[:sqs].each do |queue|
        puts "Creating queue #{queue[:name].to_s.dasherize}-#{Docket.env.downcase}"
        @sqs_connection.create_queue(queue_name: [queue[:name].to_s.dasherize, Docket.env.downcase].join('-'))
        #
        # I think there will need to be a loop here
        #
      end
    end

    def build_sns
      @manifest[:sns].each do |topic|
        arn = @sns_connection.create_topic(name: [topic[:topic].to_s.dasherize, Docket.env.downcase].join('-')).topic_arn
        puts "Create #{arn}"
        topic[:subscriptions].each do |sub|
          if sub[:protocol] == :sqs || sub[:protocol] == :cqs
            url = @sqs_connection.list_queues.queue_urls.detect {|x| x.match /#{sub[:endpoint].to_s.dasherize}-#{Docket.env.downcase}/ }
            endpoint = @sqs_connection.get_queue_attributes(queue_url: url, attribute_names: ['QueueArn']).attributes['QueueArn']
          else
            endpoint = sub[:endpoint]
          end
          puts "Create #{endpoint}"
          sub_arn = @sns_connection.subscribe(topic_arn: arn, protocol: sub[:protocol], endpoint: endpoint).subscription_arn
          sub[:attributes].each do |key, value|
            next if key.blank? || value.blank?
            puts "Setting #{key} on #{sub_arn}"
            @sns_connection.set_subscription_attributes(subscription_arn: sub_arn, attribute_name: key.to_s, attribute_value: value.to_s)
          end
        end
      end
    end

    private

      def connection_options
        {
          credentials: Docket.credentials,
          region: Docket.config.aws.region,
          endpoint: Docket.config.aws.endpoint
        }.reject { |k, v| v.blank? }
      end

  end
end
