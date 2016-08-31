module FedexSMS
  class FieldValue
    attr_accessor :field_spec, :occurrence, :value

    def initialize(field_spec, occurrence, value)
      self.field_spec = field_spec
      self.occurrence = occurrence
      self.value = value
    end

    def to_s
      id_suffix = occurrence == 0 ? "" : "-#{occurrence + 1}"
      "%d%s,\"%s\"" % [field_spec.id, id_suffix, validate!(escape(value))]
    end

    private
      def escape(str)
        str.gsub("\"", "``").tr("'", "`")
      end

      def validate!(str)
        unless field_spec.len_range.include?(str.bytesize)
          raise FieldSpec::FormatError.new("#{str.inspect} is out of range", field_spec)
        end

        regex =
            case field_spec.type
            when "A", "A/N" then /\A[a-zA-Z\d\W]*\z/
            when "N"        then /\A\d*\z|\A\d+\.\d+\z/
            when "AKE"      then /\A[^'"]*\z/
            end

        if str !~ regex
          raise FieldSpec::FormatError.new(
            "#{str.inspect} does not match expected format",
            field_spec
          )
        end

        str
      end
  end
end