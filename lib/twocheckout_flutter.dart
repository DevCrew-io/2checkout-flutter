//
//  TwoCheckoutFlutterEventsImpl.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/services.dart';

import 'twocheckout_flutter_platform_interface.dart';

/// Define a class for handling TwoCheckout events and interactions.

class TwoCheckoutFlutterEventsImpl {
  /// Instance variable to store the event handler.

  final TwoCheckoutFlutterEvents twoCheckoutFlutterEvents;

  /// Constructor to initialize the event handler.

  TwoCheckoutFlutterEventsImpl({required this.twoCheckoutFlutterEvents}) {
    /// Set up a method call handler to receive messages from native code.

    getMethodChannel().setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'showFlutterAlert':

          /// Extract title and message from the method call arguments.

          String title = call.arguments['title'];
          String message = call.arguments['message'];

          /// Call the event handler to show a dialogue.

          twoCheckoutFlutterEvents.onShowDialogue(title, message);
          break;
        case 'showLoadingSpinner':

          /// Call the event handler to show a progress bar.

          twoCheckoutFlutterEvents.onShowProgressBar();
          break;
        case 'dismissProgressbar':

          /// Call the event handler to dismiss the progress bar.

          twoCheckoutFlutterEvents.onDismissDialogue();
          break;
        case 'PaymentFlowDone':

          /// Call the event handler to show the payment confirmation screen.

          twoCheckoutFlutterEvents.onShowPaymentDoneScreen();
          break;
      }
    });
  }

  /// Method to initiate the display of payment methods.

  Future<String?> showPaymentMethods() {
    return TwocheckoutFlutterPlatform.instance.showPaymentMethods();
  }

  /// Method to obtain the Flutter platform's method channel for communication.

  MethodChannel getMethodChannel() =>
      TwocheckoutFlutterPlatform.instance.getMethodChannel();

  /// Method to set TwoCheckout API credentials.

  setTwoCheckoutCredentials(String secretKey, String merchantKey) {
    TwocheckoutFlutterPlatform.instance
        .setTwoCheckCredentials(secretKey, merchantKey);
  }
}

/// Abstract class defining event callbacks related to TwoCheckout.

abstract class TwoCheckoutFlutterEvents {
  /// Callback to show a dialogue with title and detail.

  void onShowDialogue(String title, String detail);

  /// Callback to dismiss a displayed dialogue.

  void onDismissDialogue();

  /// Callback to show a loading spinner or progress bar.

  void onShowProgressBar();

  /// Callback to hide a loading spinner or progress bar (optional).

  void onHideProgressBar();

  /// Callback to show a payment confirmation screen.

  void onShowPaymentDoneScreen();

  /// Response Return from Api call

  void onApiCallResponse();
}
