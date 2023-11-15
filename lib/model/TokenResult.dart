//
//  TokenResult.dart
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

class TokenResult {
  String? token;
  String? error;

  TokenResult.fromJson(Map<dynamic, dynamic>? json) {
    token = json?['token'];
    error = json?['error'];
  }

  Map<dynamic, dynamic> toMap() {
    return {
      "token" : token,
      "error" : error
    };
  }
}
