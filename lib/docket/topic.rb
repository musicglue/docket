module Docket
  class Topic

    attr_reader :name

    def initialize(name, connection_options={})
      @name           = name.to_s.underscore.downcase.to_sym
      @connection     = Aws.sns(options.merge(connection_options))
    end

    def to_sym
      name
    end

    def arn
      @arn ||= @connection.create_topic(name: "#{name.to_s.dasherize}-#{Docket.env}")[:topic_arn]
    end

    def publish(message)
      @connection.publish(topic_arm: arn, message: message)
    end

    def subscriptions
      unless @subscriptions.blank?
        @subscriptions = []
        @connection.list_subscriptions_by_topic(topic_arn: arn).subscriptions.each do |sub|
          @subscriptions << Docket::S3::SNS::Subscription.new(self, @connection, sub)
        end
      end
      @subscriptions
    end

    def subscribe(protocol, endpoint)
      @connection.subscribe(topic_arn: arn, protocol: protocol, endpoint: endpoint)
    end

    private

      def options
        {
          credentials: Docket.credentials,
          region: Docket.config.aws.region,
          endpoint: Docket.config.aws.endpoint
        }.reject { |k, v| v.blank? }
      end


  end
end
