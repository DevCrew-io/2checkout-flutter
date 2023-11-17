//
//  TwoCheckoutFlutterEventsImpl.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import 'package:flutter/services.dart';
import 'model/payment_form_result.dart';
import 'model/payment_method_type.dart';
import 'model/token_result.dart';
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
  showPaymentMethods({required double price, required String currency, String local = "en"}) {
    TwocheckoutFlutterPlatform.instance
        .showPaymentMethods(price, currency, local);
  }


  /// Authorizes a payment with the provided order response.
  /// Use if need to authorized payment depend on the following key contain in post order api response
  /// Credit Card: response -> PaymentDetails -> PaymentMethod -> Authorize3DS exist
  /// Paypal: response -> PaymentDetails -> PaymentMethod -> RedirectURL exist
  ///
  /// @param url The Redirect URL for payment authorization. --> Credit Card: Authorize3DS.getString("Href"),  Paypal: PaymentMethod.getString("RedirectURL")
  /// @param parameters --> Credit Card: ['avng8apitoken' : 'Authorize3DS -> Params -> avng8apitoken'],  Paypal: [:] none optional
  /// @param successReturnUrl The URL to redirect to on successful payment (default is an empty string).
  /// @param cancelReturnUrl The URL to redirect to if the payment is canceled (default is an empty string).

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

  /// Callback when the payment process failed with error.
  void paymentFailedWithError(String message);

  /// Callback when card input form is completed and call 2Checkout API here for post order with the received token.
  /// https://app.swaggerhub.com/apis-docs/2Checkout-API/api-rest_documentation/6.0-oas3#/Order/post_orders_
  void onPaymentFormComplete(PaymentFormResult paymentFormResult);

  /// Callback the event if payment is canceled.
  void authorizePaymentDidCancel();

  /// Callback the event & use 2Checkout API for checking order status.
  /// https://app.swaggerhub.com/apis-docs/2Checkout-API/api-rest_documentation/6.0#/Order/post_orders_
  void authorizePaymentDidCompleteAuthorizing(Map<dynamic, dynamic> result);
}
