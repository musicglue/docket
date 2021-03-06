module Docket
  class Builder
    include Docket::Logging

    def initialize(file_path)
      @manifest = YAML.load(File.read(file_path))[Docket.env] || {}
      @manifest = @manifest.with_indifferent_access

      config = @manifest[:config] || {}

      @sns_connection = Aws::SNS::Client.new(connection_options.merge((config[:topics] || {})))
      @sqs_connection = Aws::SQS::Client.new(connection_options.merge((config[:queues] || {})))
    end

    def build!
      if @manifest.blank?
        say_status :warning, "Manifest file blank, aborting", :yellow
        return
      end
      build_sqs if (@manifest[:queues] || []).any?
      build_sns if (@manifest[:topics] || []).any?
    end

    def build_sqs
      say_status :info, "Building #{@manifest[:queues].count} queue(s)", :light_blue

      @manifest[:queues].each do |queue|
        queue_name = [queue[:name].to_s.dasherize, Docket.env.downcase].join('-')

        say_status :info, "Queue #{queue_name} requested", :light_blue

        @sqs_connection.create_queue(queue_name: queue_name)
        queue_url = wait_for_queue queue_name

        if queue[:attributes]
          attrs = queue[:attributes]

          if attrs['RedrivePolicy'] && attrs['RedrivePolicy']['deadLetterTargetArn'].is_a?(Symbol)
            dead_letter_name  = [attrs['RedrivePolicy']['deadLetterTargetArn'].to_s.dasherize, Docket.env.downcase].join('-')
            @sqs_connection.create_queue(queue_name: dead_letter_name)
            dead_letter_url   = wait_for_queue dead_letter_name
            dead_letter_arn   = @sqs_connection.get_queue_attributes(queue_url: dead_letter_url, attribute_names: ['QueueArn']).attributes['QueueArn']
            attrs['RedrivePolicy']['deadLetterTargetArn'] = dead_letter_arn
          end
          @sqs_connection.set_queue_attributes(queue_url: queue_url, attributes: attrs.each_with_object({}) {|(k,v),o| o[k] = v.to_s })
          say_status :success, "Set #{attrs.keys.join(', ')} for #{queue_name}", :green
        end

        say_status :success, "#{queue_name} created successfully", :green
      end
    end

    def build_sns
      say_status :info, "Building #{@manifest[:topics].count} topic(s)", :light_blue

      @manifest[:topics].each do |topic|
        arn = @sns_connection.create_topic(name: [topic[:topic].to_s.dasherize, Docket.env.downcase].join('-')).topic_arn

        say_status :success, "Topic #{arn} created successfully", :green

        (topic[:subscriptions] || []).each do |sub|
          if sub[:protocol] == :sqs || sub[:protocol] == :cqs
            url = wait_for_queue "#{sub[:endpoint].to_s.dasherize}-#{Docket.env.downcase}"
            endpoint = @sqs_connection.get_queue_attributes(queue_url: url, attribute_names: ['QueueArn']).attributes['QueueArn']
          else
            endpoint = sub[:endpoint]
          end

          sub_arn = @sns_connection.subscribe(topic_arn: arn, protocol: sub[:protocol], endpoint: endpoint).subscription_arn

          say_status :success, "Subscription #{endpoint} created successfully", :green

          attributes = { RawMessageDelivery: true }.merge(sub[:attributes] || {})

          attributes.each do |key, value|
            next if key.blank? || value.blank?

            say_status :success, "Set #{key} on #{sub_arn}", :green

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

      def wait_for_queue name
        say_status :info, "Checking for existance of queue #{name}...", :light_blue

        begin
          url = @sqs_connection.get_queue_url(queue_name: name).data.queue_url
        rescue Aws::SQS::Errors::NonExistentQueue => e
          print '.'
          sleep 1
        end while url.blank?

        url
      end
  end
end
