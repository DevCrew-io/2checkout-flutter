import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'twocheckout_flutter_platform_interface.dart';

/// An implementation of [TwocheckoutFlutterPlatform] that uses method channels.
class MethodChannelTwocheckoutFlutter extends TwocheckoutFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('twocheckout_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
