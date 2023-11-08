//
//  twocheckout_flutter_method_channel.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'twocheckout_flutter_platform_interface.dart';

/// An implementation of [TwocheckoutFlutterPlatform] that uses method channels.
class MethodChannelTwocheckoutFlutter extends TwocheckoutFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('twocheckout_flutter');

  @override
  MethodChannel getMethodChannel() {
    return methodChannel;
  }

  @override
  showPaymentMethods(double price, String currency, String successReturnUrl, String cancelReturnUrl, String local) {
    final Map<String, dynamic> arguments = {
      'price': price,
      'currency': currency,
      'successReturnUrl': successReturnUrl,
      'cancelReturnUrl': cancelReturnUrl,
      'local': local
    };
    methodChannel.invokeMethod<String>('showPaymentMethods', arguments);
  }

  @override
  setTwoCheckCredentials(String secretKey, String merchantKey) {
    final Map<String, dynamic> arguments = {
      'arg1': secretKey,
      'arg2': merchantKey,
    };
    methodChannel.invokeMethod<String>('setTwoCheckCredentials', arguments);
  }

  @override
  authorizePaymentWithOrderResponse(Map<dynamic, dynamic> result) {
    methodChannel.invokeListMethod('authorizePayment', result);
  }
}
