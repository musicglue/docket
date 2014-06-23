module Docket
  class TopicDirectory
    include Enumerable

    def initialize
      @topics = {}
    end

    def [](name)
      @topics[name] || add_topic(name)
    end

    def add_topic(name, options={})
      Topic.new(name, options)
      @topics[topic.to_sym] = topic
    end

    def each(&block)
      @topics.each do |k, v|
        block.call(k, v)
      end
    end

  end
end
