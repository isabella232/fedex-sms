require "test_helper"

module FedexSMS
  class TransactionTest < Minitest::Test
    def test_new_method_is_private
      err = assert_raises(NoMethodError) { Transaction.new }
      assert_match(/protected method `new' called/, err.message)
    end
  end
end