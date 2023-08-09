package com.twocheckout.twocheckout_flutter.http

import android.util.Log
import java.nio.charset.StandardCharsets
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import kotlin.collections.HashMap

class HttpAuthenticationAPI {
    var merchantCode="254558257678"
    var secretKey = ""
    @Throws(TwoCheckoutException::class)
    fun hmacDigest(msg: String, keyString: String, algo: String?): String? {
        var digest: String? = null
        digest = try {
            val key = SecretKeySpec(keyString.toByteArray(StandardCharsets.UTF_8), algo)
            val mac: Mac = Mac.getInstance(algo)
            mac.init(key)
            val bytes: ByteArray = mac.doFinal(msg.toByteArray(StandardCharsets.US_ASCII))
            val hash = StringBuffer()
            for (aByte in bytes) {
                val hex = Integer.toHexString(0xFF and aByte.toInt())
                if (hex.length == 1) {
                    hash.append('0')
                }
                hash.append(hex)
            }
            hash.toString()
        } catch (e: NoSuchAlgorithmException) {
            throw TwoCheckoutException(
                "We encountered an error while creating the HMAC authentication.",
                0,
                e
            )
        } catch (e: InvalidKeyException) {
            throw TwoCheckoutException(
                "Error invalid key",
                0,
                e
            )
        }
        return digest
    }

    @Throws(TwoCheckoutException::class)
    fun getHeaders(): HashMap<String, String> {
        val headers: HashMap<String, String> = HashMap()
        var hash: String? = ""
        val df: DateFormat = SimpleDateFormat("y-MM-dd HH:mm:ss")
        df.timeZone = TimeZone.getTimeZone("GMT")
        val gmtDate: String = df.format(Date())
        val finalString: String =
            ""+merchantCode.length + merchantCode + gmtDate.length.toString() + gmtDate
        hash = hmacDigest(finalString, this.secretKey, "HmacMD5")
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["X-Avangate-Authentication"] =
            "code=\"" + merchantCode + "\" date=\"" + gmtDate + "\" hash=\"" + hash.toString() + "\""

        Log.d("*Header_value*", "code=\"" + merchantCode + "\" date=\"" + gmtDate + "\" hash=\"" + hash.toString() + "\"");
        return headers
    }
}