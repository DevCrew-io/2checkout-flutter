// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twocheckout_flutter/model/payment_form_result.dart';
import 'package:twocheckout_flutter/model/payment_method_type.dart';
import 'package:twocheckout_flutter/twocheckout_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final TwoCheckoutFlutterEventsImpl plugin = TwoCheckoutFlutterEventsImpl(
        twoCheckoutFlutterEvents: MockTwoCheckoutFlutterEvents());
    // final String? version = await plugin.showPaymentMethods();
    // // The version string depends on the host platform running the test, so
    // // just assert that some non-empty string is returned.
    // expect(version?.isNotEmpty, true);
  });
}

// Define a mock event handler for testing purposes.
class MockTwoCheckoutFlutterEvents extends TwoCheckoutFlutterEvents {
  @override
  void authorizePaymentDidCancel() {
    // TODO: implement authorizePaymentDidCancel
  }

  @override
  void authorizePaymentDidCompleteAuthorizing(Map result) {
    // TODO: implement authorizePaymentDidCompleteAuthorizing
  }

  @override
  void onPaymentFormComplete(PaymentFormResult paymentFormResult) {
    // TODO: implement onPaymentFormComplete
  }

  @override
  void paymentFailedWithError(String message) {
    // TODO: implement paymentFailedWithError
  }

  @override
  void paymentFormWillClose() {
    // TODO: implement paymentFormWillClose
  }

  @override
  void paymentFormWillShow() {
    // TODO: implement paymentFormWillShow
  }

  @override
  void paymentMethodSelected(PaymentMethodType paymentMethod) {
    // TODO: implement paymentMethodSelected
  }
}
