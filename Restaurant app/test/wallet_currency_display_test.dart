import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor_restaurant/helper/price_converter_helper.dart';

void main() {
  test('wallet display replaces Br with ETB and keeps the amount', () {
    expect(PriceConverter.applyDisplayCurrency('24,024 Br', 'Br'), '24,024 ETB');
    expect(PriceConverter.applyDisplayCurrency('0 Br', 'Br'), '0 ETB');
    expect(PriceConverter.applyDisplayCurrency('Br 10.50', 'Br'), 'ETB 10.50');
    expect(PriceConverter.applyDisplayCurrency('24,024 USD', 'USD'), '24,024 USD');
  });
}
