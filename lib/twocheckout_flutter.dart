//
//  TwoCheckoutFlutterEventsImpl.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:twocheckout_flutter/model/PaymentMethodType.dart';
import 'package:twocheckout_flutter/model/TokenResult.dart';

import 'model/PaymentFormResult.dart';
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
        case 'paymentFormWillShow':

          /// Callback when payment form will show.
          twoCheckoutFlutterEvents.paymentFormWillShow();

        case 'paymentFormWillClose':

          /// Callback when payment form will close.
          twoCheckoutFlutterEvents.paymentFormWillClose();

        case 'paymentMethodSelected':

          /// Callback when payment method did selected.
          twoCheckoutFlutterEvents.paymentMethodSelected(
              PaymentMethodType.fromJson(call.arguments));

        case 'paymentFailedWithError':

          /// Callback when the payment process failed with error.
          String message = call.arguments["error"] ?? "";
          twoCheckoutFlutterEvents.paymentFailedWithError(message);

        case 'paymentFormComplete':

          /// Call the event handler to use 2checkout create order api.
          PaymentFormResult result = PaymentFormResult.fromJson(call.arguments);
          twoCheckoutFlutterEvents.onPaymentFormComplete(result);

        case 'authorizePaymentDidCancel':

          /// Call the event handler view if payment is canceled.
          twoCheckoutFlutterEvents.authorizePaymentDidCancel();

        case 'authorizePaymentDidCompleteAuthorizing':

          /// Call the event handler to use 2checkout order status api.
          twoCheckoutFlutterEvents
              .authorizePaymentDidCompleteAuthorizing(call.arguments);
      }
    });
  }

  /// Method to obtain the Flutter platform's method channel for communication.
  MethodChannel getMethodChannel() =>
      TwocheckoutFlutterPlatform.instance.getMethodChannel();

  /// Method to set TwoCheckout API credentials.
  setTwoCheckoutCredentials({required String secretKey, required String merchantCode}) {
    TwocheckoutFlutterPlatform.instance
        .setTwoCheckCredentials(secretKey, merchantCode);
  }

  /// Method to get card token without ui.
  Future<TokenResult> createToken({required String name, required String creditNumber, required String cvv, required String expiryDate, String? scope}) async {
    final result = await TwocheckoutFlutterPlatform.instance
        .createToken(name: name, creditNumber: creditNumber, cvv: cvv, expiryDate: expiryDate, scope: scope);
    return TokenResult.fromJson(result);
  }

  /// Method to initiate the display of payment methods.
  showPaymentMethods(double price, String currency, {String local = "en"}) {
    TwocheckoutFlutterPlatform.instance
        .showPaymentMethods(price, currency, local);
  }

  /// Method to authorize payment with order.
  authorizePaymentWithOrderResponse(
      String url, Map<dynamic, dynamic> parameters,
      {String successReturnUrl = "", String cancelReturnUrl = ""}) {
    TwocheckoutFlutterPlatform.instance.authorizePaymentWithOrderResponse(
        url, parameters, successReturnUrl, cancelReturnUrl);
  }

}

/// Abstract class defining event callbacks related to TwoCheckout.
abstract class TwoCheckoutFlutterEvents {
  /// Callback when payment form will show.
  void paymentFormWillShow();

  /// Callback when payment form will close.
  void paymentFormWillClose();

  /// Callback when payment method did selected.
  void paymentMethodSelected(PaymentMethodType paymentMethod);

  /// Callback when the payment process failed with error..
  void paymentFailedWithError(String message);

  /// make 2Checkout API call to create an order with the received token
  /// https://app.swaggerhub.com/apis-docs/2Checkout-API/api-rest_documentation/6.0#/Order/post_orders_
  void onPaymentFormComplete(PaymentFormResult paymentFormResult);

  /// Callback the event if payment is canceled..
  void authorizePaymentDidCancel();

  /// Callback the event & use 2Checkout API for checking order status.
  /// https://app.swaggerhub.com/apis-docs/2Checkout-API/api-rest_documentation/6.0#/Order/post_orders_
  void authorizePaymentDidCompleteAuthorizing(Map<dynamic, dynamic> result);
}
