module FakeTwilio
  class Client
    Message = Struct.new(:from, :to, :body)

    cattr_accessor :messages
    self.messages = []

    def initialize
    end

    def messages
      self
    end

    def create(from:, to:, body:)
      self.class.messages << Message.new(from, to, body)
    end
  end

  class TwiMLResponse
    attr_reader :body

    def initialize
    end

    def message(body:)
      @body = body
    end

    def to_s
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Message body=\"#{body}\"/></Response>"
    end
  end
end
