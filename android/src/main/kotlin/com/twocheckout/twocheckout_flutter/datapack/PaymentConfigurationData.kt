package com.twocheckout.twocheckout_flutter.datapack

import android.content.Context

class PaymentConfigurationData(
    ctx: Context,
    price: String = "",
    merchantCode: String,
    displayUICustomization: FormUICustomizationData
) {

    var activityContext:Context = ctx
    var displayPrice:String= price
    var payButtonText:String = ""
    var merchantCodeParam:String = merchantCode
    var displayCustomization: FormUICustomizationData = displayUICustomization

}