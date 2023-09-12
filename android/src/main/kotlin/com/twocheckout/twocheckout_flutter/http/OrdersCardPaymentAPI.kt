package com.twocheckout.twocheckout_flutter.http

import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection
import kotlin.collections.HashMap

class OrdersCardPaymentAPI(currency:String,isPaypal:Boolean, onSendResultComplete: (response:String) -> Unit) {
    companion object {
        private const val cardPaymentsURL = "https://api.2checkout.com/rest/6.0/orders/"
    }
    private lateinit var httpsConnect: HttpsURLConnection
    private val currencyVal = currency
    private var errorMessage = ""
    lateinit var authHeaders:HashMap<String, String>
    private var overridePaymentsURL = ""
    private var ORDER_API_RESPONSE = "{\n  \"RefNo\": \"11541215\",\n  \"OrderNo\": 0,\n  \"ExternalReference\": \"REST_API_AVANGTE\",\n  \"Status\": \"AUTHRECEIVED\",\n  \"ApproveStatus\": \"WAITING\",\n  \"VendorApproveStatus\": \"OK\",\n  \"MerchantCode\": \"120655175030\",\n  \"Language\": \"en\",\n  \"OrderDate\": \"2020-03-11 17:33:46\",\n  \"Source\": \"testAPI.com\",\n  \"WSOrder\": \"testvendorOrder.com\",\n  \"Affiliate\": {},\n  \"HasShipping\": true,\n  \"ContainsRenewableProducts\": true,\n  \"RequestDeliveryData\": true,\n  \"BillingDetails\": {\n    \"FirstName\": \"Customer\",\n    \"LastName\": \"2Checkout\",\n    \"Email\": \"testcustomer@2Checkout.com\",\n    \"Address1\": \"Test Address\",\n    \"City\": \"LA\",\n    \"Zip\": \"12345\",\n    \"CountryCode\": \"us\",\n    \"State\": \"California\"\n  },\n  \"DeliveryDetails\": {\n    \"FirstName\": \"Customer\",\n    \"LastName\": \"2Checkout\",\n    \"Email\": \"testcustomer@2Checkout.com\",\n    \"Address1\": \"Test Address\",\n    \"City\": \"LA\",\n    \"Zip\": \"12345\",\n    \"CountryCode\": \"us\",\n    \"State\": \"California\"\n  },\n   \"PaymentDetails\": {\n    \"Type\": \"CC\",\n    \"Currency\": \"usd\",\n    \"PaymentMethod\": {\n      \"FirstDigits\": \"4111\",\n      \"LastDigits\": \"1111\",\n      \"CardType\": \"visa\",\n      \"ExpirationMonth\": \"12\",\n      \"ExpirationYear\": \"29\",\n      \"RecurringEnabled\": true,\n      \"Authorize3DS\": {\n        \"Params\": {\n          \"avng8apitoken\": \"your_token_value_here\"\n        },\n       \"Href\": \"https://www.example.com\"\n      }\n    }},\n  \"DeliveryInformation\": {\n    \"ShippingMethod\": {}\n  },\n  \"Origin\": \"API\",\n  \"AvangateCommission\": 8.5,\n  \"OrderFlow\": \"REGULAR\",\n  \"TestOrder\": false,\n  \"FxRate\": 1,\n  \"FxMarkup\": 0,\n  \"PayoutCurrency\": \"USD\",\n  \"DeliveryFinalized\": false,\n  \"Items\": [\n    {\n      \"ProductDetails\": {\n        \"Name\": \"Dynamic product\",\n        \"ShortDescription\": \"Test description\",\n        \"Tangible\": false,\n        \"IsDynamic\": true,\n        \"RenewalStatus\": false,\n        \"DeliveryInformation\": {\n          \"Delivery\": \"NO_DELIVERY\",\n          \"DeliveryDescription\": \"\",\n          \"CodesDescription\": \"\",\n          \"Codes\": []\n        }\n      },\n      \"PriceOptions\": [],\n      \"CrossSell\": {\n        \"CampaignCode\": \"CAMPAIGN_CODE\",\n        \"ParentCode\": \"MASTER_PRODUCT_CODE\"\n      },\n      \"Price\": {\n        \"UnitNetPrice\": 100,\n        \"UnitGrossPrice\": 100,\n        \"UnitVAT\": 0,\n        \"UnitDiscount\": 0,\n        \"UnitNetDiscountedPrice\": 100,\n        \"UnitGrossDiscountedPrice\": 100,\n        \"UnitAffiliateCommission\": 0,\n        \"ItemUnitNetPrice\": 0,\n        \"ItemUnitGrossPrice\": 0,\n        \"ItemNetPrice\": 0,\n        \"ItemGrossPrice\": 0,\n        \"VATPercent\": 0,\n        \"HandlingFeeNetPrice\": 0,\n        \"HandlingFeeGrossPrice\": 0,\n        \"Currency\": \"usd\",\n        \"NetPrice\": 100,\n        \"GrossPrice\": 100,\n        \"NetDiscountedPrice\": 100,\n        \"GrossDiscountedPrice\": 100,\n        \"Discount\": 0,\n        \"VAT\": 0,\n        \"AffiliateCommission\": 0\n      },\n      \"LineItemReference\": \"1002325206c9e754a019b752b5bf4f103c0f18f1\",\n      \"PurchaseType\": \"PRODUCT\",\n      \"ExternalReference\": \"\",\n      \"Quantity\": 1,\n      \"Promotion\": {\n        \"Name\": \"Regular promotion\",\n        \"Code\": \"VXVA13JRPM\",\n        \"Description\": \"description\",\n        \"StartDate\": \"2022--11-01\",\n        \"EndDate\": \"2022-11-30\",\n        \"MaximumOrdersNumber\": null,\n        \"MaximumQuantity\": null,\n        \"InstantDiscount\": false,\n        \"Coupon\": \"\",\n        \"DiscountLabel\": \"20 EUR\",\n        \"Enabled\": true,\n        \"Type\": \"REGULAR\",\n        \"Discount\": 20,\n        \"DiscountCurrency\": \"EUR\",\n        \"DiscountType\": \"FIXED\",\n        \"Promotions\": [\n          {\n            \"Name\": \"Global promotion\",\n            \"Code\": \"C03ZALY2S9\",\n            \"Description\": \"description\",\n            \"StartDate\": \"2022--11-01\",\n            \"EndDate\": \"2022-11-30\",\n            \"MaximumOrdersNumber\": null,\n            \"MaximumQuantity\": null,\n            \"InstantDiscount\": false,\n            \"Coupon\": \"\",\n            \"DiscountLabel\": \"30\",\n            \"Enabled\": true,\n            \"Type\": \"GLOBAL\",\n            \"Discount\": 30,\n            \"DiscountCurrency\": \"USD\",\n            \"DiscountType\": \"PERCENT\"\n          },\n          {\n            \"Name\": \"Order promotion\",\n            \"Code\": \"SB8ZMIUXZ5\",\n            \"Description\": \"description\",\n            \"StartDate\": \"2022--11-01\",\n            \"EndDate\": \"2022-11-30\",\n            \"MaximumOrdersNumber\": null,\n            \"MaximumQuantity\": null,\n            \"InstantDiscount\": false,\n            \"Coupon\": \"\",\n            \"DiscountLabel\": \"45 USD\",\n            \"Enabled\": true,\n            \"Type\": \"ORDER\",\n            \"Discount\": 45,\n            \"DiscountCurrency\": \"USD\",\n            \"DiscountType\": \"FIXED\"\n          }\n        ]\n      }\n    }\n  ],\n  \"Currency\": \"usd\",\n  \"NetPrice\": 100,\n  \"GrossPrice\": 100,\n  \"NetDiscountedPrice\": 100,\n  \"GrossDiscountedPrice\": 100,\n  \"Discount\": 0,\n  \"VAT\": 0,\n  \"AffiliateCommission\": 0\n}";
    private val onSendResult = onSendResultComplete
    private val isPaypalTransaction = isPaypal
    private fun setupAuthenticationHeaders() {
        for (ind in authHeaders) {
            httpsConnect.setRequestProperty(ind.key, ind.value)
        }
    }

    fun overridePaymentURL(newPaymentsUrl:String){
        overridePaymentsURL = newPaymentsUrl
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

    fun launchAPI(tokenEES:String){
        val coroutineExceptionHandler = CoroutineExceptionHandler{_, throwable ->
            throwable.printStackTrace()
        }
        MainScope().launch(Dispatchers.Default + coroutineExceptionHandler) {
            postOrdersAPI(tokenEES)
        }

    }

    private fun postOrdersAPI(tokenEES:String) {
        val inputStream: InputStream
        var url = URL(cardPaymentsURL)
        if (overridePaymentsURL.isNotEmpty()) {
            url = try{
                URL(overridePaymentsURL)
            }catch (e:Exception){
                e.printStackTrace()
                URL(cardPaymentsURL)
            }
        }
        onSendResult(ORDER_API_RESPONSE)
       /* httpsConnect = url.openConnection() as HttpsURLConnection
        httpsConnect.requestMethod = "POST"
        httpsConnect.doOutput = true
        httpsConnect.doInput = true
        httpsConnect.allowUserInteraction = true
        setupAuthenticationHeaders()
        addRequestBody(tokenEES)
        try {
            httpsConnect.connect()
            inputStream = httpsConnect.inputStream
            val result = convertInputStreamToString(inputStream)
            onSendResult(result)
            onSendResult(ORDER_API_RESPONSE)
            inputStream.close()
        } catch (e:java.lang.Exception) {
            e.printStackTrace()
            errorMessage = convertInputStreamToString(httpsConnect.errorStream)

            onSendResult('')
        }

        httpsConnect.disconnect()*/
    }

    private fun addRequestBody(tokenParam:String) {
        val requestBody = JSONObject()
        requestBody.put("Country", "BR")
        requestBody.put("Currency", currencyVal)
        requestBody.put( "CustomerIP", "91.220.121.21")
        requestBody.put("CustomerReference", "GFDFE")
        requestBody.put("ExternalCustomerReference", "IOUER")
        requestBody.put("ExternalReference", "REST_API_AVANGTE")
        requestBody.put("Language", "en")
        requestBody.put("Source", "testAPI.com")
        requestBody.put("WSOrder", "testvendorOrder.com")
        requestBody.put("Affiliate",null)
        requestBody.put("BillingDetails",getBillingDetailsJson())
        requestBody.put("PaymentDetails",addPaymentDetails(tokenParam))
        val itemsArray = JSONArray()
        itemsArray.put(addOrderItem())

        requestBody.put("Items",itemsArray)
        val outStream: OutputStream = httpsConnect.outputStream
        val outStreamWriter = OutputStreamWriter(outStream, "UTF-8")
        outStreamWriter.write(requestBody.toString())
        outStreamWriter.flush()
        outStreamWriter.close()
        outStream.close()
    }

    private fun getBillingDetailsJson():JSONObject {
        val billingDetails = JSONObject()
        billingDetails.put("Address1", "Test Address")
        billingDetails.put("City", "LA")
        billingDetails.put("CountryCode", "US")
        billingDetails.put("Email", "customer@2Checkout.com")
        billingDetails.put("FirstName", "Customer")
        billingDetails.put("LastName", "2Checkout")
        billingDetails.put("Phone", "556133127400")
        billingDetails.put("State", "DF")
        billingDetails.put("Zip", "70403-900")
        return billingDetails
    }

    private fun addOrderItem():JSONObject{
        val orderItem = JSONObject()
        orderItem.put("Quantity","1")
        orderItem.put("Name", "Dynamic product")
        orderItem.put("Description", "Test description")
        orderItem.put("IsDynamic", true)
        orderItem.put("Tangible", false)
        orderItem.put("PurchaseType", "PRODUCT")
        val price = JSONObject()
        price.put("Amount",0.01)
        orderItem.put("Price",price)
        return orderItem
    }

    private fun addPaymentDetails(eesToken:String):JSONObject {
        val paymentDetails = JSONObject()
        val paymentMethod = JSONObject()

        if (!isPaypalTransaction) {
            paymentMethod.put("EesToken", eesToken)
            paymentDetails.put("Type", "EES_TOKEN_PAYMENT")
            paymentMethod.put("Vendor3DSReturnURL", "www.test.com")
            paymentMethod.put("Vendor3DSCancelURL", "www.test.com")
        } else {
            paymentDetails.put("Type", "PAYPAL")
            paymentMethod.put("ReturnURL", "https://www.success.com")
            paymentMethod.put("CancelURL", "https://www.fail.com")
        }

        paymentDetails.put("Currency",currencyVal)
        paymentDetails.put("CustomerIP", "91.220.121.21")
        paymentDetails.put("PaymentMethod",paymentMethod)
        return paymentDetails
    }

}