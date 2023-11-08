import Foundation

final class Configuration {
    public static let shared = Configuration()

    var secretKey: String
    var merchantCode: String
    var channelName: String
    
    var price: Double
    var currency: String
    var local: String
    var successReturnUrl: String
    var cancelReturnUrl: String

    private init() {
        self.secretKey = ""
        self.merchantCode = ""
        self.channelName = "twocheckout_flutter"
        
        self.price = 0
        self.currency = "$"
        self.local = "en"
        self.successReturnUrl = ""
        self.cancelReturnUrl = ""
    }

    func fromMap(_ arguments: [String: Any]) {
        self.secretKey = arguments["arg1"] as? String ?? ""
        self.merchantCode = arguments["arg2"] as? String ?? ""
    }
    
    func updatePaymentDetails(_ arguments: [String: Any]) {
        self.price = arguments["price"] as? Double ?? 0
        self.currency = arguments["currency"] as? String ?? "$"
        self.local = arguments["local"] as? String ?? "en"
        self.successReturnUrl = arguments["successReturnUrl"] as? String ?? ""
        self.cancelReturnUrl = arguments["cancelReturnUrl"] as? String ?? ""
    }
}
