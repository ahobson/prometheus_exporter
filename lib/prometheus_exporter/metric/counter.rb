# frozen_string_literal: true

module PrometheusExporter::Metric
  class Counter < Base

    @counter_warmup_enabled = nil if !defined?(@counter_warmup_enabled)

    def self.counter_warmup=(enabled)
      @counter_warmup_enabled = enabled
    end

    def self.counter_warmup
      !!@counter_warmup_enabled
    end

    attr_reader :data

    def initialize(name, help)
      super
      File.write('/tmp/drew.log', "Counter init for [#{name}]\n", mode: 'a+')
      reset!
    end

    def type
      "counter"
    end

    def reset!
      File.write('/tmp/drew.log', "Counter reset! for [#{name}]\n", mode: 'a+')
      @data = {}
      @counter_warmup = {}
    end

    def metric_text
      @data.keys.map do |labels|
        value = warmup_counter_value(labels)
        "#{prefix(@name)}#{labels_text(labels)} #{value}"
      end.join("\n")
    end

    def to_h
      @data.dup
    end

    def remove(labels)
      File.write('/tmp/drew.log', "Counter remove for [#{name}] [#{labels.inspect}]\n", mode: 'a+')
      @counter_warmup.delete(labels)
      @data.delete(labels)
    end

    def observe(increment = 1, labels = {})
      File.write('/tmp/drew.log', "Counter observe for [#{name}] [#{labels.inspect}]\n", mode: 'a+')
      warmup_counter(labels)
      @data[labels] ||= 0
      @data[labels] += increment
    end

    def increment(labels = {}, value = 1)
      File.write('/tmp/drew.log', "Counter increment for [#{name}] [#{labels.inspect}]\n", mode: 'a+')
      warmup_counter(labels)
      @data[labels] ||= 0
      @data[labels] += value
    end

    def decrement(labels = {}, value = 1)
      File.write('/tmp/drew.log', "Counter decrement for [#{name}] [#{labels.inspect}]\n", mode: 'a+')
      warmup_counter(labels)
      @data[labels] ||= 0
      @data[labels] -= value
    end

    def reset(labels = {}, value = 0)
      File.write('/tmp/drew.log', "Counter reset for [#{name}] [#{labels.inspect}]\n", mode: 'a+')
      warmup_counter(labels)
      @data[labels] = value
    end

    private

    def warmup_counter(labels)
      if Counter.counter_warmup && !@data.has_key?(labels)
        File.write('/tmp/drew.log', "Counter warmup for [#{name}] #{labels.inspect} (#{@data.inspect}) (#{@data.object_id})\n", mode: 'a+')
        @counter_warmup[labels] = 0
      end
    end

    def warmup_counter_value(labels)
      v = @counter_warmup.delete(labels) || @data[labels]
      File.write('/tmp/drew.log', "Counter warmup value for [#{name}] #{labels.inspect}: (#{v}) (#{@counter_warmup.inspect}) (#{@data.inspect}) (#{@data.object_id})\n", mode: 'a+')
      v
    end
  end
end
