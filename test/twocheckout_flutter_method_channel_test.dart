//
//  twocheckout_flutter_method_channel_test.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twocheckout_flutter/twocheckout_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTwocheckoutFlutter platform = MethodChannelTwocheckoutFlutter();
  const MethodChannel channel = MethodChannel('twocheckout_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.showPaymentMethods(41.5, "USD", "en"), '42');
  });
}
