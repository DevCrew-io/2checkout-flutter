//
//  MockTwocheckoutFlutterPlatform.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twocheckout_flutter/model/payment_form_result.dart';
import 'package:twocheckout_flutter/model/payment_method_type.dart';
import 'package:twocheckout_flutter/twocheckout_flutter.dart';
import 'package:twocheckout_flutter/twocheckout_flutter_platform_interface.dart';
import 'package:twocheckout_flutter/twocheckout_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTwocheckoutFlutterPlatform
    with MockPlatformInterfaceMixin
    implements TwocheckoutFlutterPlatform {



  @override
  MethodChannel getMethodChannel() {
    // TODO: implement getMethodChannel
    throw UnimplementedError();
  }

  @override
  setTwoCheckCredentials(String secretKey, String merchantKey) {
    // TODO: implement setTwoCheckCredentials
    throw UnimplementedError();
  }



  @override
  showPaymentMethods(double price, String currency, String local) {
    // TODO: implement showPaymentMethods
    throw UnimplementedError();
  }

  @override
  authorizePaymentWithOrderResponse(String url, Map parameters, String successReturnUrl, String cancelReturnUrl) {
    // TODO: implement authorizePaymentWithOrderResponse
    throw UnimplementedError();
  }

  @override
  createToken({required String name, required String creditNumber, required String cvv, required String expiryDate, String? scope}) {
    // TODO: implement createToken
    throw UnimplementedError();
  }
}

void main() {
  final TwocheckoutFlutterPlatform initialPlatform =
      TwocheckoutFlutterPlatform.instance;

  test('$MethodChannelTwocheckoutFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTwocheckoutFlutter>());
  });

  test('getPlatformVersion', () async {
    TwoCheckoutFlutterEventsImpl twocheckoutFlutterPlugin =
        TwoCheckoutFlutterEventsImpl(
            twoCheckoutFlutterEvents: MockTwoCheckoutFlutterEvents());
    MockTwocheckoutFlutterPlatform fakePlatform =
        MockTwocheckoutFlutterPlatform();
    TwocheckoutFlutterPlatform.instance = fakePlatform;

    expect(await twocheckoutFlutterPlugin.showPaymentMethods(price: 41.1, currency: "USD"), '42');
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
