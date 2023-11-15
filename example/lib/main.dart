//
//  main.dart
//  com.twocheckout.twocheckout_flutter_example
//
//  Copyright © 2023 DevCrew I/O
//
import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:twocheckout_flutter/model/PaymentFormResult.dart';
import 'package:twocheckout_flutter/model/PaymentMethodType.dart';
import 'package:twocheckout_flutter/model/TokenResult.dart';
import 'package:twocheckout_flutter/twocheckout_flutter.dart';
import 'package:twocheckout_flutter_example/payment_flow_done.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements TwoCheckoutFlutterEvents {
  late final _twoCheckoutFlutterPlugin;

  @override
  void initState() {
    super.initState();

    _twoCheckoutFlutterPlugin =
        TwoCheckoutFlutterEventsImpl(twoCheckoutFlutterEvents: this);

    /// Set 2Checkout credentials
    _twoCheckoutFlutterPlugin.setTwoCheckoutCredentials(secretKey: "l_r4hBv?DV~03]dubI[#", merchantCode: "254731075008");
  }

  void showPaymentMethods() {
    /// Show payment methods using the TwoCheckoutFlutter plugin
    _twoCheckoutFlutterPlugin.showPaymentMethods(10.5, 'EUR');
  }

  createCardTokenWithoutUI() async {
    /// Method to get card token without ui.
    showProgressBar();
    TokenResult result = await _twoCheckoutFlutterPlugin.createToken(name: "Najam", creditNumber: "4111111111111111", cvv: "123", expiryDate: "12/25");

    dismissProgressBar();
    showMyDialog(result.token == null ? "Error" : "Success", result.token == null ? result.error ?? "" : "Generated Token: ${result.token ?? ""}");
  }

  /// Dialog for showing Alert messages sent from the Native side
  Future<void> showMyDialog(String title, String detail) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(detail),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Progress Bar for waiting for a response

  progressDialogue(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(),
      ),
    );
    showDialog(
      //prevent outside touch
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        //prevent Back button press
        return WillPopScope(onWillPop: () async => false, child: alert);
      },
    );
  }

  void showProgressBar() {
    progressDialogue(context);
  }

  dismissProgressBar() {
    log('Dismiss Progress bar in Flutter');
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('2Checkout Payment Gateway'),
        ),
        body: Column(
          children: [
            Image.asset("assets/images/shirt.jpg"),
            const Text(
              "T-shirt  10 USD",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("data")],
            ),
            const Text(
                "A bright and sunny 360° illustration of San Francisco wrapped around this American Apparel t-shirt. This tee, popular at the Googleplex in Mountain View, CA is now available just for you!\n\nAvailable in Aqua with the Google Now logo screen printed in Gray across chest."),
            ElevatedButton(
                onPressed: () {
                  showPaymentMethods();
                },
                child: const Text("Payment")),

            ElevatedButton(
                onPressed: () {
                  createCardTokenWithoutUI();
                },
                child: const Text("Create Card Token"))
          ],
        ),
      ),
    );
  }

  @override
  void onPaymentFormComplete(PaymentFormResult paymentFormResult) {
    /// Call 2Checkout create order api & handle its response if there is an authorized3D param in response call bellow method with required parameters.
    _twoCheckoutFlutterPlugin.authorizePaymentWithOrderResponse("https://www.google.com", { "name" : "Najam Us Saqib, iOS Developer" });
  }

  @override
  void authorizePaymentDidCancel() {
    print("Payment is cancelled");
    showMyDialog("Alert", "Payment process is cancelled by user");
  }

  @override
  void authorizePaymentDidCompleteAuthorizing(Map<dynamic, dynamic> result) {
    /// Use 2Checkout order status api to check the payment status before navigate to next screen.
    print("Dart: authorizePaymentDidCompleteAuthorizing ${result}");

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
  }

  @override
  void paymentFailedWithError(String message) {
    showMyDialog("Error", message);
  }

  @override
  void paymentFormWillClose() {
    // TODO: implement paymentFormWillClose
  }

  @override
  void paymentFormWillShow() {
    // TODO: implement paymentFormWillShow
  }

  @override
  void paymentMethodSelected(PaymentMethodType paymentMethod) {
    // TODO: implement paymentMethodSelected
  }
}
