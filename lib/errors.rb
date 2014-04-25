module Errors
  class ValidationError < RuntimeError
    attr_accessor :errors

    def initialize(message, errors)
      super(message)
      @errors = errors
    end
  end
end
