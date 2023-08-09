
import 'twocheckout_flutter_platform_interface.dart';

class TwocheckoutFlutter {
  Future<String?> getPlatformVersion() {
    return TwocheckoutFlutterPlatform.instance.getPlatformVersion();
  }
}
