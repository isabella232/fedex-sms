module FedexSMS
  class IntegrationTest
    def test_single_package_request
      transaction = FedexSMS::Transaction.build("020") do
        add( "Test Ship 1", "CUSTOMER TRANSACTION IDENTIFIER")
        add(    "Nuts.com", "RECIPIENT COMPANY")
        add( "Brian Abreu", "RECIPIENT CONTACT NAME")
        add("125 Moen St.", "RECIPIENT ADDRESS LINE 1")
        add(    "Cranford", "RECIPIENT CITY")
        add(          "NJ", "RECIPIENT STATE PROVINCE")
        add(       "07016", "RECIPIENT POSTAL CODE")
        add(  "9163972654", "RECIPIENT PHONE NUMBER")
        add(         "100", "PACKAGE WEIGHT")
        add(           "1", "PAY TYPE")
        add(          "US", "RECIPIENT COUNTRY")
        # add(          "12", "PACKAGE HEIGHT")
        # add(          "12", "PACKAGE WIDTH")
        # add(          "12", "PACKAGE LENGTH")
        add(       "10000", "DECLARED VALUE CARRIAGE VALUE")
        add(          "US", "SENDER COUNTRY CODE")
        add(         "188", "LABEL FORMAT VALUE PRINTER TYPE INDICATOR")
        add(           "N", "RESIDENTIAL DELIVERY FLAG")
        add(   "YNNNNNNNY", "OPENSHIP FLAGS")
        add(           "1", "OPENSHIP INDEX")
        add(          "01", "PACKAGING TYPE")
        add(          "01", "SERVICE TYPE")
      end

      puts transaction
    end
  end
end