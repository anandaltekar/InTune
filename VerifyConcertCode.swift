//
//  VerifyConcertCode.swift
//  in-tune
//
//  Created by Anand Altekar on 13/08/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

class VerifyConcertCode: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "VerifyConcertCode"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    
    func request(params:[String])
    {
        var concert:String = "<suidConcert>\(params[1])</suidConcert>"
        if params[1] == ""
        {
            concert = ""
        }
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><VerifyConcertCode xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession>\(concert)<sVerifyCode>\(params[2])</sVerifyCode></VerifyConcertCode></soap12:Body></soap12:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]
            selectedConcert = dictData["_suidConcert"].value!
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
    
}
