require "bigdecimal"

module FedexSMS
  # TransactionField instances provide an interface to marshal/unmarshal individual fields of a
  # FedEx Ship Manager Server transaction. Instances should be constructed with the specifications
  # of the fields as defined in the FedEx Ship Manager Server Transaction and Coding Reference
  # guide. An instance can then be used to dump values, formatting them according to the
  # specification for use in building a transaction.
  class FieldSpec
    FIELD_FORMAT_REGEX = /\A(\d+)(-\d+)?,"([^"]*)"\z/

    class FormatError < StandardError
      def initialize(message, field_spec)
        super("Transaction field error for #{field_spec.inspect}: #{message}")
      end
    end

    attr_accessor :id, :type, :multiple_occurrence, :type, :len_range, :precision, :description

    def self.parse(str)
      raise ArgumentError, "Invalid transaction field #{str.inspect}" if str !~ FIELD_FORMAT_REGEX

      id = Integer(Regexp.last_match(1), 10)
      occurrence = Regexp.last_match(2)
      occurrence = Integer(occurrence, 10) unless occurrence.nil?
      value = Regexp.last_match(3)

      [id, occurrence, value]
    end

    def initialize(id, type, multiple_occurrence, len_range, precision, description)
      self.id = id
      self.type = type
      self.multiple_occurrence = multiple_occurrence
      self.len_range = len_range
      self.precision = precision
      self.description = description
    end

    def load(str)
      raise FormatError.new(str.inspect, self) unless str =~ FIELD_FORMAT_REGEX
      unless Integer(Regexp.last_match(1)) == id
        raise FormatError.new("incorrect field id in #{str.inspect}", self)
      end

      FieldValue.new(self, RegExp.last_match(2), RegExp.last_match(1))
    end

    def inspect
      "%s(id: %d, multiple_occurrence: %s, len_range: %s, precision: %s, description: %s)" % [
        self.class, id, multiple_occurrence, len_range, precision.inspect, description
      ]
    end

    private

      def type=(type)
        unless %w(A A/N N AKE).include?(type)
          raise FormatError.new("invalid type: #{type.inspect}", self)
        end
        @type = type
      end
  end
end
