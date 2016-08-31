require "test_helper"
require "bigdecimal"

module FedexSMS
  class FieldSpecTest < Minitest::Test
    def test_parse_value
      field_spec = FieldSpec.new(12, "A", false, 1..100, nil, "faux field")

      field_value = field_spec.parse_field_value(%(12,"HELLO"))
      assert_equal(field_spec, field_value.field_spec)
      assert_equal(nil, field_value.occurrence)
      assert_equal("HELLO", field_value.value)
    end

    def test_parse_value_with_an_occurrence_index
      field_spec = FieldSpec.new(42, "A", false, 1..100, nil, "faux field")

      field_value = field_spec.parse_field_value(%(42-1,"faux value"))
      assert_equal(field_spec, field_value.field_spec)
      assert_equal(1, field_value.occurrence)
      assert_equal("faux value", field_value.value)

    end

    def test_load_fails_with_incorrect_id
      field_spec = FieldSpec.new(42, "A", false, 1..100, nil, "faux field")
      field_str = %(43,"SOMEVALUE")
      err = assert_raises(FieldSpec::FormatError) { field_spec.parse_field_value(field_str) }
      expect = "Transaction field error for %s: incorrect field id in %s" % [
        field_spec.inspect, field_str.inspect
      ]
      assert_equal(expect, err.message)
    end
  end
end
