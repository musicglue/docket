module Docket
  module Message
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
    end

    def attributes
      # NOOP
      raise NotImplementedError
    end

    def publish!
      Docket.topics[topic_name].publish(payload.to_json) if valid?
    end

    def topic_name
      self.class.to_s.underscore.dasherize.sub(/-message$/, '')
    end

    private

    def headers
      {}
    end

    def payload
      {
        header: headers.merge(type: topic_name, version: version),
        body: attributes
      }
    end

    def version
      1
    end
  end
end
