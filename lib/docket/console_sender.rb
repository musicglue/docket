module Docket
  class ConsoleSender
    include Docket::Logging

    def initialize topic, body = nil
      @topic, @body = topic, body
    end

    def send!
      error "A TOPIC is required." if @topic.blank?

      parse_message_class
      prepare_body
      instantiate_message

      @message.publish!

      say_status :info, "Message sent", :light_blue
    end

    private

    def error message
      say_status :error, message, :red
      exit 1
    end

    def instantiate_message
      begin
        @message = @message_class.new(ActiveSupport::JSON.decode @body)
      rescue => e
        error "Unable to instantiate message class #{@message_class} with attrs: #{@body}. Error was: #{e}"
      end
    end

    def prepare_body
      @body = '{}' if @body.blank?
    end

    def parse_message_class
      klass_name = "#{@topic}-message".gsub(/-/, '_').classify
      @message_class = klass_name.safe_constantize

      error "No message class found called #{klass_name}" unless @message_class
    end
  end
end
