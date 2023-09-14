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

    _twoCheckoutFlutterPlugin.setTwoCheckoutCredentials(
        "secretKey", "merchant_key");
  }

  Future<void> showPaymentMethods() async {
    /// Show payment methods using the TwocheckoutFlutter plugin

    await _twoCheckoutFlutterPlugin.showPaymentMethods();
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
                child: const Text("Payment"))
          ],
        ),
      ),
    );
  }

  @override
  void onHideProgressBar() {
    dismissProgressBar();
  }

  @override
  void onShowDialogue(String title, String detail) {
    showMyDialog(title, detail);
  }

  @override
  void onShowPaymentDoneScreen() {
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
  void onShowProgressBar() {
    progressDialogue(context);
  }

  @override
  void onDismissDialogue() {
    // TODO: implement onDismissDialogue
  }

  @override
  void onApiCallResponse() {
    // TODO: implement onApiCallResponse
  }
}
