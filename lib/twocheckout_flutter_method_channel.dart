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
  setTwoCheckCredentials(String secretKey, String merchantCode) {
    final Map<String, dynamic> arguments = {
      'secretKey': secretKey,
      'merchantCode': merchantCode,
    };
    methodChannel.invokeMethod<String>('setTwoCheckCredentials', arguments);
  }

  @override
  Future<Map<dynamic,dynamic>?> createToken({required String name, required String creditNumber, required String cvv, required String expiryDate, String? scope}) {
    final Map<String, dynamic> arguments = {
      'name': name,
      'creditCard': creditNumber,
      'cvv': cvv,
      'expirationDate': expiryDate,
      'scope': scope,
    };
    return methodChannel.invokeMapMethod('createToken', arguments);
  }

  @override
  showPaymentMethods(double price, String currency, String local) {
    final Map<String, dynamic> arguments = {
      'price': price,
      'currency': currency,
      'local': local
    };
    methodChannel.invokeMethod<String>('showPaymentMethods', arguments);
  }

  @override
  authorizePaymentWithOrderResponse(String url, Map parameters, String successReturnUrl, String cancelReturnUrl) {
    final Map<String, dynamic> arguments = {
      'url': url,
      'parameters': parameters,
      "successReturnUrl": successReturnUrl,
      "cancelReturnUrl": cancelReturnUrl
    };
    methodChannel.invokeListMethod('authorizePayment', arguments);
  }
}
