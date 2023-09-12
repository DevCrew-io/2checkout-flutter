# 2Checkout Flutter

[![pub package](https://img.shields.io/github/v/tag/DevCrew-io/2checkout-flutter)](https://pub.dev/packages/2checkout-flutter)
[![license](https://img.shields.io/badge/license-MIT-green)](https://github.com/DevCrew-io/2checkout-flutter/LICENSE)
![](https://img.shields.io/badge/Code-Dart-informational?style=flat&logo=dart&color=29B1EE)
![](https://img.shields.io/badge/Code-Flutter-informational?style=flat&logo=flutter&color=0C459C)

The 2Checkout Flutter SDK allows you to build delightful payment experiences in your native Android (for iOS work is in progress). We provide powerful and customizable UI screens, widget, and method channels for native functions access that can be used out-of-the-box to collect your users' payment details.

<img src="https://github.com/DevCrew-io/2checkout-flutter/blob/readme/screenshots/1.png" alt="Alt Text" width="300">


## Features

- **Simplified Security**: We make it simple for you to collect sensitive data such as credit card numbers and remain PCI compliant. This means the sensitive data is sent directly to 2Checkout (Now Verifone) instead of passing through your server. For more information, see our [Integration Security Guide](https://verifone.cloud/docs/2checkout/Documentation).
- **Payment methods**: Accepting more payment methods helps your business expand its global reach and improve checkout conversion.
- **SCA-Ready**: The SDK automatically performs native 3D Secure authentication if needed to comply with Strong Customer Authentication.
- **Native UI**: We provide native screens and elements to securely collect payment details on Android and iOS.
- **Pre-built payments UI**: Learn how to integrate Payment Sheet, the new pre-built payments UI for mobile apps. This pre-built UI lets you accept cards and Paypal out of the box.

## Recommended usage

If you're selling digital products or services within your app, (e.g. subscriptions, in-game currencies, game levels, access to premium content, or unlocking a full version), you must use the app store's in-app purchase APIs. See Apple's and Google's guidelines for more information. For all other scenarios you can use this SDK to process payments via 2checkout.

## Installation

To install the 2Checkout Flutter plugin, use the following Dart package command:

```bash
dart pub add twocheckout_flutter
```

## Requirements
### Android Requirements

To ensure proper functionality on Android devices, please make sure to follow these steps:

1. Use Android 4.0 (API level 19) and above.
2. Utilize Kotlin version 1.7.0 and above.
3. Ensure you are using an up-to-date Android Gradle build tools version.
4. Use an up-to-date Gradle version accordingly.
5. Implement `PluginRegistry.ActivityResultListener` for handling `onActivityResults`.
6. Remember to rebuild the app after making the above changes, as these changes may not take effect with hot reload.

If you encounter difficulties while setting up the package on Android, join the discussion for support.

# Usage
## Card Payments
You can handle card payments using two methods: PayPal integration and Card Form.

## Financial Connections
The latest SDK also supports financial connections. Refer to the documentation to learn more about setting it up.

## Dart API
The library offers several methods for handling 2Checkout-related actions:

```dart
Future<String?> showPaymentMethods()
MethodChannel getMethodChannel()
setTwoCheckoutCredentials(String secretKey, String merchantKey)
```

### Initialization of 2Checkout SDK
```dart
_twoCheckoutFlutterPlugin.setTwoCheckoutCredentials(
"secretKey", "merchant_key");
```

Customization of native code on the Flutter side makes it easier for Flutter developers to perform actions such as displaying alert dialogues, dismissing/loading spinners, and navigating to customized pages.

```dart
    _twoCheckoutFlutterPlugin
        .getMethodChannel()
        .setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'showFlutterAlert':
          String title = call.arguments['title'];
          String message = call.arguments['message'];
          showMyDialog(title, message);
          break;
        case 'dismissProgressbar':
          dismissProgressBar();
          break;
        case 'showLoadingSpinner':
          progressDialogue(context);
          break;
        case 'PaymentFlowDone':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaymentFlowDoneScreen(
                label: 'Customer label',
                amount: '10 USD',
                ref: 'ref',
              ),
            ),
          );
          break;
        default:
          // Handle an unknown method call or provide an error response.
          break;
      }
    });
```

# Running the Example App

To run the example app, follow these steps:

1. Navigate to the example folder: `cd example`.
2. Install the dependencies: `flutter pub get`.
3. Set up environment variables for the Flutter app and a local backend.
4. Obtain your secret and Merchant key from the 2Checkout dashboard.
5. Set the keys in the function called `_twoCheckoutFlutterPlugin.setTwoCheckoutCredentials("secretKey", "merchant_key")`.

Here is the [list of test cards](https://verifone.cloud/docs/2checkout/Documentation/09Test_ordering_system/01Test_payment_methods) on the official 2Checkout platform.

6. Run Flutter: `flutter run`.

# Contributing

You can help us make this project better by contributing. Feel free to open a new issue or submit a pull request.
