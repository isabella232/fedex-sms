require 'English'
require "fedex-sms/field_spec"
require "fedex-sms/field_value"
require "fedex-sms/field_registry"

module FedexSMS
  class Transaction
    class ParseError < StandardError
    end

    class <<self
      protected :new
    end

    def self.build(transaction_code, registry = FIELD_REGISTRY, &blk)
      new(registry) do |transaction|
        transaction.add(transaction_code, "TRANSACTION CODE")
        yield(transaction)
        transaction.add("", "END OF RECORD INDICATOR")
      end
    end

    def self.load(str, registry = FIELD_REGISTRY)
      new(registry) do |transaction|
        transaction.send(:load, str.strip)
      end
    end

    def initialize(registry = FIELD_REGISTRY)
      @registry = registry
      @field_values = []
      @contents = ""

      yield(self)

      freeze
    end

    def add(value, field_desc)
      return if value.nil?

      field_spec = @registry.fetch(field_desc)
      occurrence = @field_values.count { |value| value.field_spec == field_spec }
      field_value = FieldValue.new(field_spec, occurrence, value)

      @field_values << field_value
      @contents << field_value.to_s
    end

    def get(description)
      @field_values.
          select { |value| value.field_spec.description == description }.
          map(&:value)
    end

    def fetch(description)
      get(description).tap do |values|
        raise KeyError, "No value found for #{description.inspect}" if values.empty?
      end
    end

    def get_first(description)
      get(description).first
    end

    def fetch_first(description)
      fetch(description).first
    end

    def each(&blk)
      @field_values.each(&blk)
    end

    def to_s
      @contents
    end

    def to_ruby
      max_value_width = @field_values.map{ |field_value| field_value.value.inspect.length }.max
      max_value_width = 36 if max_value_width > 36

      str = "#{self.class}.build(#{fetch_first("TRANSACTION CODE").inspect}) do |t|"

      @field_values.each do |field_value|
        next if field_value.field_spec.description == "END OF RECORD INDICATOR"
        next if field_value.field_spec.description == "TRANSACTION CODE"

        str << "\n  t.add %#{max_value_width}s, %s # (%d)" % [
          field_value.value, field_value.field_spec.description, field_value.field_spec.id
        ].map(&:inspect)
      end

      str << "\nend"
    end

    private

      def load(str)
        l = 0
        r = 0
        len = str.length

        while r < str.length
          c = 0
          while r < len
            c += 1 if str[r] == "\""
            break if c == 2
            r += 1
          end

          begin
            raise ArgumentError, "Invalid field" if r == len

            field_str = str[l..r]
            field_id, occurrence, value = FieldSpec.parse(field_str)
            field_spec = @registry.fetch(field_id) do
              FieldSpec.new(field_id, "AKE", true, 0..Float::INFINITY, nil, "FIELD #{field_id}")
            end

            @field_values << FieldValue.new(field_spec, occurrence, value)
          rescue
            r = [r, len - 1].min
            msg = "Parse error: #{$ERROR_INFO.message}. Near col: #{l}..#{r}: #{str[l..r].inspect}"
            raise ParseError, msg
          end

          l = r += 1
        end

        @contents = str
      end
  end
end
