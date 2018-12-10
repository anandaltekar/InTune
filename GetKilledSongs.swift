//
//  VerifyHostUser.swift
//  in-tune
//
//  Created by Anand Altekar on 20/08/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

class GetKilledSongs: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "GetKilledSongs"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetKilledSongs xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidConcert>\(params[1])</suidConcert></GetKilledSongs></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_idSongs"]
            var arrIDs:[Int] = []
            for item in dictData.children {
                arrIDs.append(Int(item.value!)!)
                DBChats.updateSong(Int(item.value!)!, updateField: Const.DBFIELD_KILLD_COUNT, value: Const.SONG_KILLED)
            }
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
}
