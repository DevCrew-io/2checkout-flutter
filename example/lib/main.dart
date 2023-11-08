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

  void showPaymentMethods() {
    /// Show payment methods using the TwocheckoutFlutter plugin


    _twoCheckoutFlutterPlugin.showPaymentMethods(10.5, 'EUR');
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

  @override
  void onPaymentFormComplete(PaymentFormResult paymentFormResult) {
    Map<dynamic, dynamic> response = {
      "AdditionalFields": null,
      "AffiliateCommission": 0,
      "Affiliate": {
        "AffiliateCode": null,
        "AffiliateSource": null,
        "AffiliateName": null,
        "AffiliateUrl": null
      },
      "ApproveStatus": "WAITING",
      "AvangateCommission": 80.39,
      "BillingDetails": {
        "Address1": "",
        "Address2": "",
        "City": "LA",
        "Company": null,
        "CountryCode": "br",
        "Email": "customer@example.com",
        "FirstName": "Customer",
        "FiscalCode": "056.027.963-98",
        "LastName": "2Checkout",
        "Phone": "556133127400",
        "State": "Distrito Federal",
        "TaxOffice": "null,",
        "Zip": "70403-900"
      },
      "Currency": "brl",
      "CustomerDetails": null,
      "DeliveryDetails": {
        "Address1": "",
        "Address2": "",
        "City": "LA",
        "Company": null,
        "CountryCode": "br",
        "Email": "customer@example.com",
        "FirstName": "Customer",
        "LastName": "2Checkout",
        "Phone": "556133127400",
        "State": "Distrito Federal",
        "Zip": "70403-900"
      },
      "Discount": 0,
      "Errors": {
        "ORDER_ERROR": "GATEWAY_ACCEPT"
      },
      "ExternalReference": "REST_API_AVANGTE",
      "ExtraDiscount": null,
      "ExtraDiscountPercent": null,
      "ExtraInformation": {
        "RetryFailedPaymentLink": "https://store.avancart.com/order/finish.php?id=2Xrl83GEleyOsn3tfdXcZXKBy4sdasdas"
      },
      "ExtraMargin": null,
      "ExtraMarginPercent": null,
      "FinishDate": null,
      "GiftDetails": null,
      "GrossDiscountedPrice": 384.45,
      "GrossPrice": 384.45,
      "HasShipping": false,
      "Items": [
        {
          "AdditionalFields": null,
          "Code": "my_subscription_1",
          "CrossSell": null,
          "Price": {
            "AffiliateCommission": 0,
            "Currency": "brl",
            "Discount": 0,
            "GrossDiscountedPrice": 384.45,
            "GrossPrice": 384.45,
            "NetDiscountedPrice": 384.45,
            "NetPrice": 384.45,
            "UnitAffiliateCommission": 0,
            "UnitDiscount": 0,
            "UnitGrossDiscountedPrice": 384.45,
            "UnitGrossPrice": 384.45,
            "UnitNetDiscountedPrice": 384.45,
            "UnitNetPrice": 384.45,
            "UnitVAT": 0,
            "VAT": 0
          },
          "PriceOptions": [
            {
              "Code": "USERS",
              "Options": [
                "oneuser1"
              ],
              "Required": false
            }
          ],
          "ProductDetails": {
            "ExtraInfo": null,
            "Name": "2Checkout Subscription",
            "RenewalStatus": false,
            "Subscriptions": null
          },
          "Promotion": {
            "Name": "Regular promotion",
            "Code": "F07GBYJ2F6",
            "Description": "description",
            "StartDate": "2022--11-01",
            "EndDate": "2022-11-30",
            "MaximumOrdersNumber": null,
            "MaximumQuantity": null,
            "InstantDiscount": false,
            "Coupon": "",
            "DiscountLabel": "30",
            "Enabled": true,
            "Type": "REGULAR",
            "Discount": 30,
            "DiscountCurrency": "USD",
            "DiscountType": "PERCENT"
          },
          "Quantity": 1,
          "SKU": "NewSubscriptionPurchase",
          "Trial": null
        }
      ],
      "Language": "en",
      "LocalTime": null,
      "NetDiscountedPrice": 384.45,
      "NetPrice": 384.45,
      "OrderDate": "2016-02-08 19:19:53",
      "OrderFlow": "REGULAR",
      "OrderNo": 0,
      "Origin": "API",
      "PODetails": null,
      "PartnerCode": null,
      "PartnerMargin": null,
      "PartnerMarginPercent": null,
      "PaymentDetails": {
        "Type": "PAYPAL_EXPRESS",
        "Currency": "USD",
        "CustomerIP": "91.220.121.21",
        "PaymentMethod": {
          "RedirectUrl": "http://www.success.com",
          "RecuringEnabled": false,
          "Vendor3DSReturnURL": null,
          "Vendor3DSCancelURL": null,
          "InstallmentsNumber": null
        }
      },
      "Promotions": [
        {
          "Name": "global promotion",
          "Code": "F07GBYJ2F6",
          "Description": "description",
          "StartDate": "2022--11-01",
          "EndDate": "2022-11-30",
          "MaximumOrdersNumber": null,
          "MaximumQuantity": null,
          "InstantDiscount": false,
          "Coupon": "",
          "DiscountLabel": "30",
          "Enabled": true,
          "Type": "GLOBAL",
          "Discount": 30,
          "DiscountCurrency": "USD",
          "DiscountType": "PERCENT"
        }
      ],
      "RefNo": "1234567",
      "ShopperRefNo": null,
      "Source": "testAPI.com",
      "Status": "PENDING",
      "TestOrder": false,
      "VAT": 0,
      "VendorApproveStatus": "OK"
    };
    _twoCheckoutFlutterPlugin.authorizePaymentWithOrderResponse(response);
  }
}
