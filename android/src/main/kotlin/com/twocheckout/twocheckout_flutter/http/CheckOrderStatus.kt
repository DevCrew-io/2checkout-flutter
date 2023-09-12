package com.twocheckout.twocheckout_flutter.http

import android.util.Log
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection

class CheckOrderStatus(onCheckOrderComplete: (response:String) -> Unit) {
    companion object {

        private const val orderStatusUrl = "https://api.2checkout.com/rest/6.0/orders/"

        /// Expected Response for Order Status response. you can set this response to check your flow before approval of your 2checkout account.

        private val orderStatusResponse = "{\n  \"RefNo\": \"11541215\",\n  \"OrderNo\": 0,\n  \"ExternalReference\": \"REST_API_AVANGTE\",\n  \"Status\": \"AUTHRECEIVED\",\n  \"ApproveStatus\": \"WAITING\",\n  \"VendorApproveStatus\": \"OK\",\n  \"MerchantCode\": \"120655175030\",\n  \"Language\": \"en\",\n  \"OrderDate\": \"2020-03-11 17:33:46\",\n  \"Source\": \"testAPI.com\",\n  \"WSOrder\": \"testvendorOrder.com\",\n  \"Affiliate\": {},\n  \"HasShipping\": true,\n  \"ContainsRenewableProducts\": true,\n  \"RequestDeliveryData\": true,\n  \"BillingDetails\": {\n    \"FirstName\": \"Customer\",\n    \"LastName\": \"2Checkout\",\n    \"Email\": \"testcustomer@2Checkout.com\",\n    \"Address1\": \"Test Address\",\n    \"City\": \"LA\",\n    \"Zip\": \"12345\",\n    \"CountryCode\": \"us\",\n    \"State\": \"California\"\n  },\n  \"DeliveryDetails\": {\n    \"FirstName\": \"Customer\",\n    \"LastName\": \"2Checkout\",\n    \"Email\": \"testcustomer@2Checkout.com\",\n    \"Address1\": \"Test Address\",\n    \"City\": \"LA\",\n    \"Zip\": \"12345\",\n    \"CountryCode\": \"us\",\n    \"State\": \"California\"\n  },\n  \"PaymentDetails\": {\n    \"Type\": \"CC\",\n    \"Currency\": \"usd\",\n    \"PaymentMethod\": {\n      \"FirstDigits\": \"4111\",\n      \"LastDigits\": \"1111\",\n      \"CardType\": \"visa\",\n      \"ExpirationMonth\": \"12\",\n      \"ExpirationYear\": \"29\",\n      \"RecurringEnabled\": true\n    },\n    \"CustomerIP\": \"91.220.121.21\"\n  },\n  \"DeliveryInformation\": {\n    \"ShippingMethod\": {}\n  },\n  \"Origin\": \"API\",\n  \"AvangateCommission\": 8.5,\n  \"OrderFlow\": \"REGULAR\",\n  \"TestOrder\": false,\n  \"FxRate\": 1,\n  \"FxMarkup\": 0,\n  \"PayoutCurrency\": \"USD\",\n  \"DeliveryFinalized\": false,\n  \"Items\": [\n    {\n      \"ProductDetails\": {\n        \"Name\": \"Dynamic product\",\n        \"ShortDescription\": \"Test description\",\n        \"Tangible\": false,\n        \"IsDynamic\": true,\n        \"RenewalStatus\": false,\n        \"DeliveryInformation\": {\n          \"Delivery\": \"NO_DELIVERY\",\n          \"DeliveryDescription\": \"\",\n          \"CodesDescription\": \"\",\n          \"Codes\": []\n        }\n      },\n      \"PriceOptions\": [],\n      \"CrossSell\": {\n        \"CampaignCode\": \"CAMPAIGN_CODE\",\n        \"ParentCode\": \"MASTER_PRODUCT_CODE\"\n      },\n      \"Price\": {\n        \"UnitNetPrice\": 100,\n        \"UnitGrossPrice\": 100,\n        \"UnitVAT\": 0,\n        \"UnitDiscount\": 0,\n        \"UnitNetDiscountedPrice\": 100,\n        \"UnitGrossDiscountedPrice\": 100,\n        \"UnitAffiliateCommission\": 0,\n        \"ItemUnitNetPrice\": 0,\n        \"ItemUnitGrossPrice\": 0,\n        \"ItemNetPrice\": 0,\n        \"ItemGrossPrice\": 0,\n        \"VATPercent\": 0,\n        \"HandlingFeeNetPrice\": 0,\n        \"HandlingFeeGrossPrice\": 0,\n        \"Currency\": \"usd\",\n        \"NetPrice\": 100,\n        \"GrossPrice\": 100,\n        \"NetDiscountedPrice\": 100,\n        \"GrossDiscountedPrice\": 100,\n        \"Discount\": 0,\n        \"VAT\": 0,\n        \"AffiliateCommission\": 0\n      },\n      \"LineItemReference\": \"1002325206c9e754a019b752b5bf4f103c0f18f1\",\n      \"PurchaseType\": \"PRODUCT\",\n      \"ExternalReference\": \"\",\n      \"Quantity\": 1,\n      \"Promotion\": {\n        \"Name\": \"Regular promotion\",\n        \"Code\": \"VXVA13JRPM\",\n        \"Description\": \"description\",\n        \"StartDate\": \"2022--11-01\",\n        \"EndDate\": \"2022-11-30\",\n        \"MaximumOrdersNumber\": null,\n        \"MaximumQuantity\": null,\n        \"InstantDiscount\": false,\n        \"Coupon\": \"\",\n        \"DiscountLabel\": \"20 EUR\",\n        \"Enabled\": true,\n        \"Type\": \"REGULAR\",\n        \"Discount\": 20,\n        \"DiscountCurrency\": \"EUR\",\n        \"DiscountType\": \"FIXED\",\n        \"Promotions\": [\n          {\n            \"Name\": \"Global promotion\",\n            \"Code\": \"C03ZALY2S9\",\n            \"Description\": \"description\",\n            \"StartDate\": \"2022--11-01\",\n            \"EndDate\": \"2022-11-30\",\n            \"MaximumOrdersNumber\": null,\n            \"MaximumQuantity\": null,\n            \"InstantDiscount\": false,\n            \"Coupon\": \"\",\n            \"DiscountLabel\": \"30\",\n            \"Enabled\": true,\n            \"Type\": \"GLOBAL\",\n            \"Discount\": 30,\n            \"DiscountCurrency\": \"USD\",\n            \"DiscountType\": \"PERCENT\"\n          },\n          {\n            \"Name\": \"Order promotion\",\n            \"Code\": \"SB8ZMIUXZ5\",\n            \"Description\": \"description\",\n            \"StartDate\": \"2022--11-01\",\n            \"EndDate\": \"2022-11-30\",\n            \"MaximumOrdersNumber\": null,\n            \"MaximumQuantity\": null,\n            \"InstantDiscount\": false,\n            \"Coupon\": \"\",\n            \"DiscountLabel\": \"45 USD\",\n            \"Enabled\": true,\n            \"Type\": \"ORDER\",\n            \"Discount\": 45,\n            \"DiscountCurrency\": \"USD\",\n            \"DiscountType\": \"FIXED\"\n          }\n        ]\n      }\n    }\n  ],\n  \"Currency\": \"usd\",\n  \"NetPrice\": 100,\n  \"GrossPrice\": 100,\n  \"NetDiscountedPrice\": 100,\n  \"GrossDiscountedPrice\": 100,\n  \"Discount\": 0,\n  \"VAT\": 0,\n  \"AffiliateCommission\": 0\n}";

    }
    private val sendCheckStatus = onCheckOrderComplete
    private lateinit var httpsConnect: HttpsURLConnection

    private var errorMessage = ""
    lateinit var authHeaders:HashMap<String, String>

    private fun setupAuthenticationHeaders() {
        for (ind in authHeaders) {
            httpsConnect.setRequestProperty(ind.key, ind.value)
        }
    }

    fun launchAPI(refParam:String) {
        val coroutineExceptionHandler = CoroutineExceptionHandler{_, throwable ->
            throwable.printStackTrace()
        }
        MainScope().launch(Dispatchers.Default + coroutineExceptionHandler) {
            checkOrdersAPI(refParam)
        }
        checkOrdersAPI(refParam)
    }

    private fun checkOrdersAPI(reference: String) {
        val inputStream: InputStream
        val checkStatusUrl = "$orderStatusUrl$reference/"
        val url = URL(checkStatusUrl)

        ///Please uncomment the following line to set the expected response and check the flow
        /// sendCheckStatus(orderStatusResponse)

        httpsConnect = url.openConnection() as HttpsURLConnection
        httpsConnect.requestMethod = "GET"
        setupAuthenticationHeaders()

        try {
            httpsConnect.connect()
            inputStream = httpsConnect.inputStream
            val result = convertInputStreamToString(inputStream)
            sendCheckStatus(result)
            inputStream.close()
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            errorMessage = convertInputStreamToString(httpsConnect.errorStream)

        }

    }

    private fun addRequestBody(refNO:String) {
        val requestBody = JSONObject()

        requestBody.put("ApproveStatus", "OK")
        requestBody.put("Newer", "")
        requestBody.put( "Status", "")

        requestBody.put("StartDate", "")
        requestBody.put("EndDate", "")

        requestBody.put("PartnerOrders", false)
        requestBody.put("ExternalRefNo", refNO)

        requestBody.put("Page", "")
        requestBody.put("WSOrder", "testvendorOrder.com")
        requestBody.put("Limit",0)


        val outStream: OutputStream = httpsConnect.outputStream
        val outStreamWriter = OutputStreamWriter(outStream, "UTF-8")
        outStreamWriter.write(requestBody.toString())
        outStreamWriter.flush()
        outStreamWriter.close()
        outStream.close()
    }

    private fun convertInputStreamToString(inputStreamParam: InputStream):String{
        if (inputStreamParam == null) return ""
        val reader = BufferedReader(inputStreamParam.reader())
        var content: String
        content = ""
        reader.use { reader ->
            content = reader.readText()
        }
        return content
    }
}