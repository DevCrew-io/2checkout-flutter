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
  Future<String?> showPaymentMethods() async {
    final version = await methodChannel.invokeMethod<String>('showPaymentMethods');
    return version;
  }
 @override
  MethodChannel getMethodChannel() {
    return methodChannel;
  }
  @override
  setTwoCheckCredentials(String secretKey, String merchantKey) {
    final Map<String, dynamic> arguments = {
      'arg1': secretKey,
      'arg2': merchantKey,
    };
     methodChannel.invokeMethod<String>('setTwoCheckCredentials',arguments);
  }
}
