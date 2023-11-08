//
//  PaymentFormResult.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

class PaymentFormResult {
  late String cardHolder;
  late String paymentMethod;
  late String token;
  late bool isCardSaveOn;

  PaymentFormResult(
      {required this.cardHolder,
        required this.paymentMethod,
        required this.token,
        required this.isCardSaveOn
       });

  PaymentFormResult.fromJson(Map<dynamic, dynamic> json) {
    cardHolder = json['cardHolder'] ?? "";
    paymentMethod = json['paymentMethod'] ?? "";
    token = json['token'] ?? "";
    isCardSaveOn = json['isCardSaveOn'] ?? false;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      "cardHolder" : cardHolder,
      "paymentMethod" : paymentMethod,
      "token" : token,
      "isCardSaveOn" : isCardSaveOn
    };
  }
}