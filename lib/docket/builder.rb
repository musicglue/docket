module Docket
  class Builder

    def initialize(file_path, config={})
      @sns_connection = Aws.sns(connection_options.merge(config[:sns]))
      @sqs_connection = Aws.sqs(connection_options.merge(config[:sqs]))

      @manifest = YAML.load(file_path)[Docket.env].with_indifferent_access
    end

    def build!
      build_sqs if @manifest[:sqs].any?
      build_sns if @manifest[:sns].any?
    end

    def build_sqs
      @manifest[:sqs].each do |queue|
        puts "Creating queue #{queue.to_s.dasherize}-#{Docket.env.downcase}"
        @sqs_connection.create_queue([queue[:name].to_s.dasherize, Docket.env.downcase].join('-'))
        #
        # I think there will need to be a loop here
        #
      end
    end

    def build_sns
      @manifest[:sns].each do |topic|
        arn = @sns_connection.create_topic [topic[:topic].to_s.dasherize, Docket.env.downcase].join('-'))
        puts "Create #{arn}"
        topic[:subscriptions].each do |sub|
          if sub[:protocol] == 'sqs' || sub[:protocol] == 'cqs'
            endpoint = @sqs_connection.list_queues.queue_urls.detect {|x| x.match /#{sub[:endpoint].to_s.dasherize}-#{Docket.env.downcase}/ }
          else
            endpoint = sub[:endpoint]
          end
          puts "Create #{endpoint}"
          sub_arn = @sns_connection.subscribe(topic_arn: arn, protocol: sub[:protocol], endpoint: endpoint)
          sub[:attributes].each do |key, value|
            puts "Setting #{key} on #{sub_arn}"
            @sns_connection.set_subscription_attributes(subscription_arn: sub_arn, attribute_name: key, attribute_value: value)
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
