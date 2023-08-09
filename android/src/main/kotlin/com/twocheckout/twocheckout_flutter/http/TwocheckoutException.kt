package com.twocheckout.twocheckout_flutter.http

class TwoCheckoutException(error:String,errorNr:Int,e:Exception): Throwable() {
    val exceptionObj = e
    val errorMessage = error
    val nr = errorNr
}