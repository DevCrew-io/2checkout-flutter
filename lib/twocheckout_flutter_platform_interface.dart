//
//  twocheckout_flutter_platform_interface.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'twocheckout_flutter_method_channel.dart';

abstract class TwocheckoutFlutterPlatform extends PlatformInterface {
  /// Constructs a TwocheckoutFlutterPlatform.
  TwocheckoutFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static TwocheckoutFlutterPlatform _instance =
      MethodChannelTwocheckoutFlutter();

  /// The default instance of [TwocheckoutFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelTwocheckoutFlutter].
  static TwocheckoutFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TwocheckoutFlutterPlatform] when
  /// they register themselves.
  static set instance(TwocheckoutFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  MethodChannel getMethodChannel() {
    throw UnimplementedError('getMethodChannel() has not been implemented.');
  }

  setTwoCheckCredentials(String secretKey, String merchantCode) {
    throw UnimplementedError(
        'setTwoCheckCredentials() has not been implemented.');
  }

  Future<Map<dynamic,dynamic>?> createToken({required String name, required String creditNumber, required String cvv, required String expiryDate, String? scope}) {
    throw UnimplementedError(
        'createToken() has not been implemented.');
  }

  showPaymentMethods(double price, String currency, String local) {
    throw UnimplementedError('showPaymentMethods() has not been implemented.');
  }

  authorizePaymentWithOrderResponse(String url, Map<dynamic, dynamic> parameters, String successReturnUrl, String cancelReturnUrl) {
    throw UnimplementedError(
        'authorizePaymentWithOrderResponse() has not been implemented.');
  }
}
