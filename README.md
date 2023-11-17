# 2Checkout Flutter SDK

[![pub package](https://img.shields.io/pub/v/com.twocheckout.twocheckout_flutter)](https://pub.dev/packages/2checkout-flutter)
[![license](https://img.shields.io/badge/license-MIT-green)](https://github.com/DevCrew-io/2checkout-flutter/LICENSE)
![](https://img.shields.io/badge/Code-Dart-informational?style=flat&logo=dart&color=29B1EE)
![](https://img.shields.io/badge/Code-Flutter-informational?style=flat&logo=flutter&color=0C459C)

The 2Checkout Flutter SDK wrapper for [2checkout-android-sdk](https://github.com/2Checkout/2checkout-android-sdk) and [2checkout-ios-sdk](https://github.com/2Checkout/2checkout-ios-sdk) allows you to build delightful payment experiences in your native Android and iOS. We provide powerful and customizable UI screens, widget, and method channels for native functions access that can be used out-of-the-box to collect your users' payment details.

The 2Checkout Flutter SDK is designed to be easy to integrate into your application. With the 2Checkout Flutter SDK, you can easily tokenize card details, handle 3D Secure verification, and authorize PayPal payments.

<img src="https://github.com/DevCrew-io/2checkout-flutter/blob/readme/screenshots/1.png" alt="Alt Text" width="300">


## Features

- **Simplified Security**: We make it simple for you to collect sensitive data such as credit card numbers and remain PCI compliant. This means the sensitive data is sent directly to 2Checkout (Now Verifone) instead of passing through your server. For more information, see our [Integration Security Guide](https://verifone.cloud/docs/2checkout/Documentation).
- **Payment methods**: Accepting more payment methods helps your business expand its global reach and improve checkout conversion.
- **SCA-Ready**: The SDK automatically performs native 3D Secure authentication if needed to comply with Strong Customer Authentication.
- **Native UI**: We provide native screens and elements to securely collect payment details on Android and iOS.
- **Pre-built payments UI**: Learn how to integrate Payment Sheet, the new pre-built payments UI for mobile apps. This pre-built UI lets you accept cards and Paypal out of the box.

## Supported Payment Methods

- Credit Card Tokenization
- 3D Secure Authorization
- Paypal Payment Authorization

## Recommended usage

If you're selling digital products or services within your app, (e.g. subscriptions, in-game currencies, game levels, access to premium content, or unlocking a full version), you must use the app store's in-app purchase APIs. See Apple's and Google's guidelines for more information. For all other scenarios you can use this SDK to process payments via 2checkout.

## Requirements
### Android Requirements

- Use Android 4.0 (API level 19) and above.
- Utilize Kotlin version 1.7.0 and above.
- Ensure you are using an up-to-date Android Gradle build tools version.
- Use an up-to-date Gradle version accordingly.
- Remember to rebuild the app after making the above changes, as these changes may not take effect with hot reload.

### iOS Requirements

- Xcode 10.2 or higher
- Swift 5.0 or higher
- iOS 12 or higher

If you encounter difficulties while setting up the package on Android, join the discussion for support.


## Installation

To install the 2Checkout Flutter plugin, use the following Dart package command:

```bash
dart pub add twocheckout_flutter
```

## Dart API
The library offers several methods for handling 2Checkout-related actions: 

Callback when payment form will show.
 ```dart
  void paymentFormWillShow();
```

Callback when payment form will close.
```dart
  void paymentFormWillClose();
```

Callback when a payment method did selected.
```dart
  void paymentMethodSelected(PaymentMethodType paymentMethod);
```

Callback when the payment process failed with error.
```dart
  void paymentFailedWithError(String message);
```

Callback when card input form is completed and call 2Checkout API here for [post order](https://app.swaggerhub.com/apis-docs/2Checkout-API/api-rest_documentation/6.0-oas3#/Order/post_orders_) with the received token.
```dart
  void onPaymentFormComplete(PaymentFormResult paymentFormResult);
```

Callback when payment is canceled.
```dart
  void authorizePaymentDidCancel();
```
Callback when 3D auth will be completed and here  you can call 2Checkout order status ("orders/\(refNo)") API here to check the payment transactio status.
```dart
   void authorizePaymentDidCompleteAuthorizing(Map<dynamic, dynamic> result);
```

## Usage

### Initialization of 2Checkout SDK
```dart
  _twoCheckoutFlutterPlugin.setTwoCheckoutCredentials(secretKey: "Your_Key", merchantCode: "Your_Code");
```

### Start 2Checkout Payment Flow
```dart
  _twoCheckoutFlutterPlugin.showPaymentMethods(price: 10.5, currency: "USD", local: "en");
```

### Authorize the Card 3DS or PayPal payment using the authorizePaymentWithOrderResponse method. 

```dart
  /// Authorizes a payment with the post order response.
  /// If need to authorized payment depending on the following key contain in post order api response
  /// Credit Card: response -> PaymentDetails -> PaymentMethod -> Authorize3DS exist
  /// Paypal: response -> PaymentDetails -> PaymentMethod -> RedirectURL exist
  ///
  /// @param url The Redirect URL for payment authorization. --> Credit Card: Authorize3DS.getString("Href"),  Paypal: PaymentMethod.getString("RedirectURL")
  /// @param parameters --> Credit Card: ['avng8apitoken' : 'Authorize3DS -> Params -> avng8apitoken'],  Paypal: [:] none optional
  /// @param successReturnUrl The URL to redirect to on successful payment (default is an empty string).
  /// @param cancelReturnUrl The URL to redirect to if the payment is canceled (default is an empty string).
  ///
  _twoCheckoutFlutterPlugin.authorizePaymentWithOrderResponse(
      String url, Map<dynamic, dynamic> parameters,
      {String successReturnUrl = "", String cancelReturnUrl = ""});
```

## Card tokenisation without UI

A method that can be used to generate a payment token based on provided card data.
```dart
    TokenResult result = await _twoCheckoutFlutterPlugin.createToken(name: "CARD_HOLDER_NAME", creditNumber: "CARD_NUMBER", cvv: "xxx", expiryDate: "xx/xx");
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

## Author

[DevCrew I/O](https://devcrew.io/)
<h3 align=“left”>Connect with Us:</h3>
<p align="left">
<a href="https://devcrew.io" target="blank"><img align="center" src="https://devcrew.io/wp-content/uploads/2022/09/logo.svg" alt="devcrew.io" height="35" width="35" /></a>
<a href="https://www.linkedin.com/company/devcrew-io/mycompany/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="mycompany" height="30" width="40" /></a>
<a href="https://github.com/DevCrew-io" target="blank"><img align="center" src="https://cdn-icons-png.flaticon.com/512/733/733553.png" alt="DevCrew-io" height="32" width="32" /></a>
</p>
