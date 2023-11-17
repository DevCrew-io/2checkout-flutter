//
//  PaymentMethodType.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

enum PaymentMethodType {
  creditCard("Credit Card"),
  paypal("Paypal"),
  unknown("");

  const PaymentMethodType(this.rawValue);

  final String rawValue;

  static PaymentMethodType fromValue(String rawValue) {
    switch (rawValue) {
      case "Credit Card":
        return PaymentMethodType.creditCard;
      case "Paypal":
        return PaymentMethodType.paypal;
      default:
        return PaymentMethodType.unknown;
    }
  }

  static PaymentMethodType fromJson(Map<dynamic, dynamic> json) {
    String value = json['paymentMethod'] ?? "";
    return PaymentMethodType.fromValue(value);
  }
}
