
import 'twocheckout_flutter_platform_interface.dart';

class TwocheckoutFlutter {
  Future<String?> showPaymentMethods() {
    return TwocheckoutFlutterPlatform.instance.showPaymentMethods();
  }
}
