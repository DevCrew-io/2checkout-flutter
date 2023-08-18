//
//  MockTwocheckoutFlutterPlatform.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twocheckout_flutter/twocheckout_flutter.dart';
import 'package:twocheckout_flutter/twocheckout_flutter_platform_interface.dart';
import 'package:twocheckout_flutter/twocheckout_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTwocheckoutFlutterPlatform
    with MockPlatformInterfaceMixin
    implements TwocheckoutFlutterPlatform {

  @override
  Future<String?> showPaymentMethods() => Future.value('42');

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
}

void main() {
  final TwocheckoutFlutterPlatform initialPlatform = TwocheckoutFlutterPlatform.instance;

  test('$MethodChannelTwocheckoutFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTwocheckoutFlutter>());
  });

  test('getPlatformVersion', () async {
    TwocheckoutFlutter twocheckoutFlutterPlugin = TwocheckoutFlutter();
    MockTwocheckoutFlutterPlatform fakePlatform = MockTwocheckoutFlutterPlatform();
    TwocheckoutFlutterPlatform.instance = fakePlatform;

    expect(await twocheckoutFlutterPlugin.showPaymentMethods(), '42');
  });
}
