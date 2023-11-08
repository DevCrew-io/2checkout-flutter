//
//  MockTwocheckoutFlutterPlatform.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twocheckout_flutter/model/PaymentFormResult.dart';
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
  authorizePaymentWithOrderResponse(Map result) {
    // TODO: implement authorizePaymentWithOrderResponse
    throw UnimplementedError();
  }

  @override
  showPaymentMethods(double price, String currency, String successReturnUrl, String cancelReturnUrl, String local) {
    // TODO: implement showPaymentMethods
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

    // expect(await twocheckoutFlutterPlugin.showPaymentMethods(), '42');
  });
}

// Define a mock event handler for testing purposes.
class MockTwoCheckoutFlutterEvents extends TwoCheckoutFlutterEvents {
  @override
  void onShowDialogue(String title, String detail) {}

  @override
  void onDismissDialogue() {}

  @override
  void onShowProgressBar() {}

  @override
  void onHideProgressBar() {}

  @override
  void onShowPaymentDoneScreen() {}

  @override
  void onApiCallResponse() {}

  @override
  void onPaymentFormComplete(PaymentFormResult paymentFormResult) {}
}
