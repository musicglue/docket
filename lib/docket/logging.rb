module Docket
  module Logging
    module_function

    def escape string
      string.gsub(/"/, '"')
    end

    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def format_backtrace backtrace
      backtrace.map { |line| %("#{line}") }.join(', ')
    end

    def format_hash hash
      hash.map do |k, v|
        v = escape v.to_s
        %(#{k}="#{v}")
      end.join ' '
    end

    def debug data, error = nil
      format :debug, data, error
    end

    def info data, error = nil
      format :info, data, error
    end

    def warn data, error = nil
      format :warn, data, error
    end

    def error data, error = nil
      format :error, data, error
    end

    def format level, data, error = nil
      if data.is_a?(StandardError) && error.nil?
        data = nil
        error = data
      end

      data = format_hash(data) if data.is_a? Hash

      error = format_hash(
        error: error.to_s,
        backtrace: format_backtrace(error.backtrace)) if error

      string = "level=#{level} #{data} #{error}".strip

      logger.send level, string
    end
  end
end
