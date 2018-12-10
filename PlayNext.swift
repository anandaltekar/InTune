//
//  PlayNext.swift
//  in-tune
//
//  Created by Anand Altekar on 20/08/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

class PlayNext: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "PlayNext"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><PlayNext xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidSong>\(params[1])</suidSong></PlayNext></soap:Body></soap:Envelope>"
/*        "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><PlayNext xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidSong>\(params[1])</suidSong></PlayNext></soap:Body></soap:Envelope>"
*/        
        
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
}
