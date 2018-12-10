//
//  Registration.swift
//  in-tune
//
//  Created by Anand Altekar on 07/08/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation
class Registration: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "Registration"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var suidSession:String = ""
    var suidUser:String = ""
    var userType:Int = 0
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><Registration xmlns='http://tempuri.org/'><sfbUserId>\(params[0])</sfbUserId><sfbProfilePicLink>\(params[1])</sfbProfilePicLink><sfbProfileLink>\(params[2])</sfbProfileLink><sEmailId>\(params[3])</sEmailId><sFullName>\(params[4])</sFullName><nGender>\(params[5])</nGender><sGCMCode>\(params[6])</sGCMCode><sDeviceOS>\(params[7])</sDeviceOS><sDeviceGuid>\(params[8])</sDeviceGuid></Registration></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]
            self.suidSession = dictData["_suidSession"].value!
            self.suidUser = dictData["_suidUser"].value!
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
    
}

