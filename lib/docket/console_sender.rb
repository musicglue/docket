module Docket
  class ConsoleSender
    include Docket::Logging

    def initialize topic, body = nil
      @topic, @body = topic, body
    end

    def send!
      if @topic.blank?
        error log_data.merge error: 'topic is required'
        exit 1
      end

      parse_message_class
      prepare_body
      instantiate_message

      @message.publish!

      error log_data.merge at: 'message_sent', topic: @topic
    end

    private

    def log_data
      { component: 'docket_console_sender' }
    end

    def instantiate_message
      begin
        @message = @message_class.new(ActiveSupport::JSON.decode @body)
      rescue => e
        error log_data.merge(at: 'instantiate_message', message_class: @message_class, body: @body), e
        exit 1
      end
    end

    def parse_message_class
      klass_name = "#{@topic}-message".gsub(/-/, '_').classify
      @message_class = klass_name.safe_constantize

      unless @message_class
        error log_data.merge(at: 'parse_message_class', unknown_class: klass_name)
        exit 1
      end
    end

    def prepare_body
      @body = '{}' if @body.blank?
    end
  end
end
