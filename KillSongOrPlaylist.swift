//
//  KillSongOrPlaylist.swift
//  in-tune
//
//  Created by Anand Altekar on 20/08/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

class KillSongOrPlaylist: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "KillSongOrPlaylist"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><KillSongOrPlaylist xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidSongOrPlaylist>\(params[1])</suidSongOrPlaylist><songOrPlaylist>\(params[2])</songOrPlaylist></KillSongOrPlaylist></soap:Body></soap:Envelope>"
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
    