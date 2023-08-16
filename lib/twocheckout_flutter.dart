
import 'package:flutter/services.dart';

import 'twocheckout_flutter_platform_interface.dart';

class TwocheckoutFlutter {
  Future<String?> showPaymentMethods() {
    return TwocheckoutFlutterPlatform.instance.showPaymentMethods();
  }
  MethodChannel getMethodChannel() => TwocheckoutFlutterPlatform.instance.getMethodChannel();

  setTwoCheckoutCredentials(String secretKey, String merchantKey){
    TwocheckoutFlutterPlatform.instance.setTwoCheckCredentials(secretKey, merchantKey);
  }
}
