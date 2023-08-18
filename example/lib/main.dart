//
//  main.dart
//  com.twocheckout.twocheckout_flutter_example
//
//  Copyright © 2023 DevCrew I/O
//
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:twocheckout_flutter/twocheckout_flutter.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
      home:MyApp()));

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _twocheckoutFlutterPlugin = TwocheckoutFlutter();
  final _twoCheckoutFlutterPlugin = TwocheckoutFlutter();
  @override
  void initState() {
    super.initState();
    _twoCheckoutFlutterPlugin.setTwoCheckoutCredentials("secretKey", "merchantKey");
    _twoCheckoutFlutterPlugin.getMethodChannel().setMethodCallHandler((MethodCall call) async {
      if (call.method == 'showFlutterAlert') {
        String title = call.arguments['title'];
        String message = call.arguments['message'];
        print("Flutter receive a ");
        //_showMyDialog();
        progressDialogue(context);
      }
    });
  }

  Future<void> showPaymentMethods() async {
    await _twocheckoutFlutterPlugin.showPaymentMethods() ;
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  progressDialogue(BuildContext context) {
    //set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('2Checkout Payment Gateway'),
        ),
        body: Column(
          children: [
            Image.asset("assets/products/shirt.jpg"),
            const Text(
              "T-shirt  10 USD",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("data")],),
            const Text(
                "A bright and sunny 360° illustration of San Francisco wrapped around this American Apparel t-shirt. This tee, popular at the Googleplex in Mountain View, CA is now available just for you!\n\nAvailable in Aqua with the Google Now logo screen printed in Gray across chest."),
            ElevatedButton(onPressed: () {
              showPaymentMethods();
            }, child: const Text("Payment"))
          ],
        ),
      ),
    );
  }
}
