module Docket
  module Message
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
    end

    def topic_name
      self.class.message.class.to_s.underscore.dasherize.sub(/-message$/, '')
    end

    def payload
      {
        header: {
          type: topic_name
        },
        body: attributes
      }
    end

    def attributes
      # NOOP
      raise NotImplementedError
    end

    def publish!
      if valid?
        Docket.topics[topic_name].publish!(payload.to_json)
      end
    end

  end
end
