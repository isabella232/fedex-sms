require "test_helper"
require "English"

module FedexSMS
  class FieldValueTest < Minitest::Test
    def test_escape
      assert_equal("`", FieldValue.escape("'"))
      assert_equal("``", FieldValue.escape("\""))
    end

    def test_to_s
      field_spec = FieldSpec.new(1234, "A", false, 1..100, nil, "TEST FIELD NAME")

      field_value = FieldValue.new(field_spec, nil, "TEST VALUE")
      assert_equal(%(1234,"TEST VALUE"), field_value.to_s)

      field_value = FieldValue.new(field_spec, 99, "TEST VALUE")
      assert_equal(%(1234-99,"TEST VALUE"), field_value.to_s)

      field_value = FieldValue.new(field_spec, nil, %('TEST' "VALUE"))
      assert_equal(%(1234,"`TEST` ``VALUE``"), field_value.to_s)
    end

    def test_alpha_validation
      field_spec = FieldSpec.new(1, "A", false, 0..10, nil, "faux field")

      assert_validation(field_spec, "HEllo")
      assert_validation(field_spec, "WO")
      assert_validation(field_spec, "")
      assert_validation(field_spec, "ABCDEFGHIJ")

      refute_validation(field_spec, "_")
      refute_validation(field_spec, "ABCDEFGHIJK")
    end

    def test_numeric_validation
      field_spec = FieldSpec.new(1, "N", false, 1..5, 2, "faux field")

      assert_validation(field_spec, "0")
      assert_validation(field_spec, "99999")
      assert_validation(field_spec, "001")
      assert_validation(field_spec, "100")
      assert_validation(field_spec, "12345")

      refute_validation(field_spec, "1.12345")
      refute_validation(field_spec, "123456.2")
      refute_validation(field_spec, "123456")
      refute_validation(field_spec, "1.A")
      refute_validation(field_spec, "A.123")
      refute_validation(field_spec, "A.A")
    end

    def test_alpha_numeric_validation
      field_spec = FieldSpec.new(1, "A/N", false, 1..10, nil, "faux field")

      assert_validation(field_spec, "HEll0WO12")
      assert_validation(field_spec, "0123456789")
      assert_validation(field_spec, "123 !@H%")

      refute_validation(field_spec, "_")
      refute_validation(field_spec, "")
    end

    private

      def assert_validation(field_spec, val)
        field_value = FieldValue.new(field_spec, nil, val)
        field_value.send(:validate!, val)
      ensure
        flunk("Unexpected error in validation: #{$ERROR_INFO.message}") unless $ERROR_INFO.nil?
      end

      def refute_validation(field_spec, val)
        field_value = FieldValue.new(field_spec, nil, val)
        err = assert_raises { field_value.send(:validate!, val) }
        assert_kind_of(FieldSpec::FormatError, err)
        err
      end
  end
end
