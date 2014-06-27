module Docket
  module Logging
    extend ActiveSupport::Concern

    def say_status status, message, colour
      output = []
      output << "[#{status.to_s.upcase.colorize(colour)}]".ljust(30)
      output << message
      puts output.join(' ')
    end
  end
end
