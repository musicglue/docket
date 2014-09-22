module Docket
  class Topic
    attr_reader :name

    def initialize name
      @name = name.to_s.underscore.downcase.to_sym

      attrs = {}
      attrs[:endpoint] = Docket.config.sns.endpoint unless Docket.config.sns.endpoint.blank?

      @sns = Aws::SNS::Client.new attrs
    end

    def arn
      @arn ||= @sns.create_topic(name: "#{name.to_s.dasherize}-#{Docket.env}")[:topic_arn]
    end

    def publish message
      @sns.publish topic_arn: arn, message: message
    end

    def to_sym
      name
    end
  end
end
