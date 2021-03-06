require 'minitest/autorun'
require 'minitest/pride'
require './currency'
require './currency_converter'
require './different_currency_code_error'


class CurrencyTest < MiniTest::Test
  def test_currency_class_exists
    assert Currency
  end

  def test_created_with_amount_and_currency_code
    currency = Currency.new(3, :RUB)
    assert currency.amount == 3.00
    assert currency.currency_code.length == 3
  end

  def test_equals_other_currency_object
    currency = Currency.new(3, :RUB)
    currency1 = Currency.new(3, :RUB)
    currency2 = Currency.new(3, :USD)
    currency3 = Currency.new(4, :USD)
    assert currency == currency1
    refute currency == currency2
    refute currency2 == currency3
  end

  def test_add_two_currency_objects
    currency = Currency.new(3, :RUB)
    currency1 = Currency.new(3, :RUB)
    currency_result = currency + currency1
    assert currency_result.amount == 6
    assert currency_result.currency_code == :RUB
  end

  def test_subtract_two_currency_objects
    currency = Currency.new(3, :RUB)
    currency1 = Currency.new(3, :RUB)
    currency_result1 = currency - currency1
    assert currency_result1.amount == 0
    assert currency_result1.currency_code == :RUB
  end

  def test_raises_error_code_when_currencies_dont_match
    currency1 = Currency.new(3, :RUB)
    currency2 = Currency.new(3, :USD)
    assert_raises DifferentCurrencyCodeError do
      currency1 + currency2
    end
    assert_raises DifferentCurrencyCodeError do
      currency1 - currency2
    end
  end

  def test_currency_can_be_multiplied_by_fixnum_or_float
    currency = Currency.new(3, :RUB)
    result = currency * 10
    result1 = currency * 1.5
    assert_equal result.amount , 30
    assert_equal result1.amount, 4.5
  end

  def test_currency_converter_class_exists
    assert CurrencyConverter
  end

  def test_initializes_with_currency_to_conversion_hash
    currency = CurrencyConverter.new({USD: 1,
                                      CAD: 1.24})
    assert_equal 1.24, currency.conversion_rates[:CAD]
  end

  def test_converting_to_same_currency_code_will_return_same_amount
    current = CurrencyConverter.new({USD: 1,
                                     EUR: 0.89})
    assert current.convert(Currency.new(3, :USD), :USD) == Currency.new(3, :USD)
  end

  def test_convert_to_different_currency_code
    current = CurrencyConverter.new({USD: 1,
                                     EUR: 0.89})
    assert current.convert(Currency.new(3, :USD), :EUR) == Currency.new(2.67, :EUR)
  end

  def test_initializes_with_hash_of_three_currencies
    currencies = CurrencyConverter.new({USD: 1,
                                        CAD: 1.24,
                                        EUR: 0.89})
    assert_equal 0.89, currencies.conversion_rates[:EUR]
  end

  def test_convert_between_any_two_included_currencies
    currencies = CurrencyConverter.new({USD: 1,
                                        CAD: 1.24,
                                        EUR: 0.89})
    assert currencies.convert(Currency.new(3, :USD), :CAD) == Currency.new(3.72, :CAD)
    assert currencies.convert(Currency.new(3, :EUR), :CAD) == Currency.new(4.18, :CAD)
  end

  def raise_error_when_trying_to_convert_to_or_from_unknown_currencies
    currencies = CurrencyConverter.new({USD: 1,
      CAD: 1.24,
      EUR: 0.89})
      assert_raises UnknownCurrencyCodeError do
        currencies.convert(Currency.new(3, :RUB), :USD)
      end
      assert_raises UnknownCurrencyCodeError do
        currencies.convert(Currency.new(3, :EUR), :GBP)
      end
  end
end
