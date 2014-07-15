module Docket
  class MessageInvalid < StandardError
    def initialize(errors)
      super(errors.full_messages.join(', '))
    end
  end
end
