module Docket
  module Message
    extend ActiveSupport::Concern

    included do
      include ActiveAttr::Model
    end

    module ClassMethods
      def topic_name
        to_s.underscore.dasherize.sub /-message$/, ''
      end
    end

    def publish!
      raise Docket::MessageInvalid, errors if invalid?
      Docket.topics[topic_name].publish(payload.to_json)
    end

    def topic_name
      self.class.topic_name
    end

    def to_h
      payload
    end

    private

    def docket_id
      @docket_id ||= SecureRandom.uuid
    end

    def headers
      {}
    end

    def payload
      {
        header: headers.merge(id: docket_id, type: topic_name, version: version),
        body: attributes
      }
    end

    def version
      1
    end
  end
end
