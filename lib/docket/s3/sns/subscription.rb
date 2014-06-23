module Docket
  module S3
    module SNS
      class Subscription

        def initialize(topic, connection, subscription_struct)
          @topic      = topic
          @connection = connection
          @arn        = subscription_struct.subscription_arn
          @owner      = subscription_struct.owner
          @endpont    = subscription_struct.endpoint
        end

        def attributes
          @attributes ||= @connection.get_subscription_attributes(subscription_arn: @arn)
        end

        def set_attributes(attributes)
          @connection.set_subscription_attributes(attributes.reverse_merge({subscription_arn: @arn}))
        end

      end
    end
  end
end
