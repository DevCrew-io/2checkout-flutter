import 'package:flutter/material.dart';
import 'package:twocheckout_flutter_example/constants.dart';

class PaymentFlowDoneScreen extends StatelessWidget {
  final String? label;
  final String? amount;
  final String? ref;
  final String? currencyParam;
  final String? transactionType;

  const PaymentFlowDoneScreen(
      {super.key,
      required this.label,
      required this.amount,
      required this.ref,
      this.currencyParam,
      this.transactionType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(top: 6.0),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * .1,
                        child: Image.asset('assets/images/verifone.png'),
                      ),
                      // SizedBox(height: 4.0),
                      Text(
                        amount!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 1.5,
                    color: white,
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.175,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue,
                    ),
                    padding: const EdgeInsets.all(23.0),
                    child: Image.asset(
                      'assets/images/check_mark.png',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  const Text(
                    'Thank you for your payment',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 1.5,
                    color: white,
                  ),
                  const SizedBox(height: 20.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Label',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Customer Value',
                        style: TextStyle(
                          color: grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$10',
                        style: TextStyle(
                          color: grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reference',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Reference Value',
                        style: TextStyle(
                          color: grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(blue),
                    ),
                    child: const Text(
                      'Back to Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Secure payments provided by Verifone',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
